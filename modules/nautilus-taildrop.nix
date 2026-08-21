# modules/nautilus-taildrop.nix
{ pkgs, lib, ... }:

let
  src = pkgs.fetchFromGitHub {
    owner = "Balazsmi";
    repo = "Nautilus-Taildrop";
    rev = "v1.0.0";
    hash = "sha256-FhazYKt/oixcsbknGFj5C5eiJxjHi37TFfB9t3toWHk=";
  };

  pythonEnv = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);

  giTypelibPath = lib.makeSearchPathOutput "lib" "lib/girepository-1.0" [
    pkgs.gtk4
    pkgs.libadwaita
    pkgs.pango
    pkgs.graphene
    pkgs.gdk-pixbuf
    pkgs.glib
    pkgs.harfbuzz
    pkgs.gobject-introspection
  ];

  # "Send via Taildrop" — Nautilus Scripts entry (GTK4/libadwaita device picker)
  send-via-taildrop = pkgs.stdenvNoCC.mkDerivation {
    pname = "nautilus-send-via-taildrop";
    version = "1.0.0";
    inherit src;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall
      install -Dm755 send-via-taildrop.py $out/bin/send-via-taildrop

      wrapProgram $out/bin/send-via-taildrop \
        --prefix PATH : ${lib.makeBinPath [ pkgs.tailscale pkgs.libnotify pythonEnv ]} \
        --prefix GI_TYPELIB_PATH : "${giTypelibPath}"
      runHook postInstall
    '';
  };

  # Auto-receive daemon — written directly in Nix (not patched from upstream's
  # script) so the timeout-wrapped `tailscale file get --wait` logic is
  # guaranteed present, with no risk of a silent substituteInPlace mismatch.
  taildrop-auto-receive = pkgs.writeShellApplication {
    name = "taildrop-auto-receive";
    runtimeInputs = [ pkgs.tailscale pkgs.libnotify pkgs.coreutils ];
    text = ''
      DOWNLOADS_DIR="$HOME/Downloads"
      mkdir -p "$DOWNLOADS_DIR"

      newest_file() {
        find "$1" -maxdepth 1 -type f -printf '%T@\t%p\n' 2>/dev/null \
          | sort -rn | head -n 1 | cut -f2-
      }

      echo "taildrop-auto-receive: starting"
      while true; do
        # -k 10: if TERM doesn't kill it within 60s, force SIGKILL after 10 more seconds
        if timeout -k 10 60 tailscale file get --wait --conflict=rename "$DOWNLOADS_DIR/"; then
          sleep 0.5
          filepath=$(newest_file "$DOWNLOADS_DIR")
          if [ -z "$filepath" ] || [ ! -e "$filepath" ]; then
            filepath="$DOWNLOADS_DIR"
            msg="Saved to Downloads folder."
          else
            msg="Received: $(basename "$filepath")"
          fi
          echo "taildrop-auto-receive: received -> $filepath"
          ACTION=$(notify-send --app-name="" --icon=none \
            --action="default=Open" "Taildrop Received" "$msg" || true)
          if [ "$ACTION" = "default" ]; then
            xdg-open "$filepath" &
          fi
        else
          rc=$?
          if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
            echo "taildrop-auto-receive: wait timed out (rc=$rc), retrying"
          else
            echo "taildrop-auto-receive: file get exited rc=$rc, retrying"
          fi
        fi
      done
    '';
  };
in
{
  home.packages = [ send-via-taildrop taildrop-auto-receive ];

  # Right-click a file in Nautilus -> Scripts -> "Send via Taildrop"
  home.file.".local/share/nautilus/scripts/Send via Taildrop" = {
    source = "${send-via-taildrop}/bin/send-via-taildrop";
    executable = true;
  };

  systemd.user.services.taildrop-auto-receive = {
    Unit = {
      Description = "Tailscale Taildrop auto-receive daemon";
      After = [ "network-online.target" "tailscaled.service" "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${taildrop-auto-receive}/bin/taildrop-auto-receive";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}

