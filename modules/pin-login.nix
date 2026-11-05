{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.my.pinLogin;
  pinDir = "/var/lib/pin-login";
  openssl = lib.getExe pkgs.openssl;

  # pam_exec hands the typed authtok on stdin (nul-terminated)
  checkPin = pkgs.writeShellScript "check-pin" ''
    set -u
    [ "''${PAM_SERVICE:-}" = gdm-password ] || exit 1
    [[ "''${PAM_USER:-}" =~ ^[a-z_][a-z0-9_-]*$ ]] || exit 1
    hash_file=${pinDir}/$PAM_USER
    [ -f "$hash_file" ] || exit 1

    IFS= read -r -d "" pin || true
    [ -n "$pin" ] || exit 1
    hash=$(< "$hash_file")
    salt=$(cut -d '$' -f 3 <<< "$hash")
    [ "$(printf '%s\n' "$pin" | ${openssl} passwd -6 -salt "$salt" -stdin)" = "$hash" ]
  '';

  setPin = pkgs.writeShellScriptBin "set-login-pin" ''
    set -eu
    if [ "$(id -u)" -ne 0 ]; then
      exec sudo "$0" "$@"
    fi
    user=''${SUDO_USER:-root}
    if [ "''${1:-}" = --remove ]; then
      rm -f ${pinDir}/"$user"
      echo "removed login pin for $user"
      exit 0
    fi

    read -r -s -p "new pin for $user: " pin; echo
    read -r -s -p "confirm pin: " pin2; echo
    [ "$pin" = "$pin2" ] || { echo "pins do not match" >&2; exit 1; }
    [[ "$pin" =~ ^[0-9]{${toString cfg.minLength},}$ ]] \
      || { echo "pin must be at least ${toString cfg.minLength} digits" >&2; exit 1; }

    umask 077
    printf '%s\n' "$pin" | ${openssl} passwd -6 -stdin > ${pinDir}/"$user"
    echo "login pin set for $user"
  '';
in
{
  options.my.pinLogin = {
    enable = lib.mkEnableOption "pin as an alternative to the password at the gdm login/lock screen";
    minLength = lib.mkOption {
      type = lib.types.ints.positive;
      default = 4;
      description = "minimum pin length accepted by set-login-pin";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ setPin ];

    systemd.tmpfiles.rules = [ "d ${pinDir} 0700 root root -" ];

    # gdm-password substacks login, so slot in after unix-early has prompted
    # (and gnome-keyring has grabbed the authtok) but before the real unix check.
    # check-pin rejects every service other than gdm-password.
    security.pam.services.login.rules.auth.pin = {
      order = config.security.pam.services.login.rules.auth.unix.order - 10;
      control = "sufficient";
      modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
      args = [
        "quiet"
        "expose_authtok"
        "${checkPin}"
      ];
    };
  };
}
