{
  pkgs,
  lib,
  ...
}:

let
  wallpaper = pkgs.fetchurl {
    url = "https://thegoose.cloud/apps/files_sharing/publicpreview/KxE95nD6qKaEs2R?file=/&fileId=646&x=2256&y=1504&a=true&etag=a8774b83fbdae6cd3e1e6df1c8663408";
    sha256 = "sha256-aoKHI9n02Gki1ISEyrWW1C/hRoqhmgr2BK6ugng7XjI=";
  };

  # patched copyous from pr#545762
  nixpkgs-545762-drv = pkgs.applyPatches {
    src = pkgs.path;
    patches = [
      (pkgs.fetchpatch2 {
        url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/545762.patch";
        hash = "sha256-f1cQGZgwUWOzFPB43v8N3/k/REzJ3t2coH1xA3iRTck=";
      })
    ];
  };
  nixpkgs-545762 = import nixpkgs-545762-drv { inherit (pkgs.stdenv) system; };

  copyous = nixpkgs-545762.gnomeExtensions.copyous;
in
{
  services.xserver.enable = true;
  services.xserver.excludePackages = with pkgs; [ xterm ];
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable = false;
  services.desktopManager.gnome.sessionPath = [ pkgs.gdm ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
  ];

  catppuccin = {
    enable = true;
    autoEnable = true;
  };

  # declarative gnome settings
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            copyous.extensionUuid
            pkgs.gnomeExtensions.gsconnect.extensionUuid
            pkgs.gnomeExtensions.unblank.extensionUuid
          ];
          favorite-apps = [
            "zen-twilight.desktop"
            "org.gnome.Console.desktop"
          ];
        };

        "org/gnome/desktop/datetime" = {
          automatic-timezone = true;
        };
        "org/gnome/system/location" = {
          enabled = true;
        };

        "org/gnome/shell/extensions/copyous" = {
          open-clipboard-dialog-shortcut = [ "<Super>v" ];
          toggle-incognito-mode-shortcut = [ "<Control><Super>v" ];
        };

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          clock-show-weekday = true;
        };

        "org/gnome/desktop/background" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri = "file://" + wallpaper;
          picture-uri-dark = "file://" + wallpaper;
        };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-from = 20.0;
          night-light-schedule-to = 6.0;
        };

        "org/gnome/desktop/interface".show-battery-percentage = true;
        "org/gnome/desktop/calendar".show-weekdate = true;

        "org/gnome/desktop/wm/keybindings" = {
          close = [
            "<Super>q"
            "<Alt>F4"
          ];
        };

        "org/gnome/shell/keybindings" = {
          toggle-message-tray = [ "<Super>z" ];
          show-screenshot-ui = [
            "Print"
            "<Super><Shift>s"
          ];
        };

        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "Open terminal";
          command = "gapplication launch org.gnome.Console";
          binding = "<Super>t";
        };

        "org/gnome/settings-daemon/plugins/media-keys" = {
          www = [ "<Super>w" ];
          home = [ "<Super>e" ];
        };
      };
    }
  ];

  environment.systemPackages = with pkgs; [
    # gnome shell extensions
    copyous
    gnomeExtensions.gsconnect
    gnomeExtensions.unblank

    # gnome core apps
    # gnome-console
    nautilus
    gnome-calculator
    gnome-calendar
    gnome-system-monitor
    gnome-disk-utility
    gnome-logs
    loupe
    papers
    showtime
    snapshot
    baobab
  ];
}
