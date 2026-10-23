{ pkgs, lib, ... }:

let
  wallpaper = pkgs.fetchurl {
    name = "wallpaper.png";
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
  programs.obsidian = {
    enable = true;
    cli.enable = true;
    defaultSettings.themes.AnuPpuccin.enable = true;
    defaultSettings.communityPlugins = {
      obsidian-livesync.enable = true;
      obsidian-style-settings.enable = true;
    };
  };

  # hide nvim.desktop
  xdg.desktopEntries."nvim" = {
    name = "Neovim";
    noDisplay = true;
  };

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;
      maximize = true;
    };
  };

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    copyous
  ];

  fonts.fontconfig.enable = true;

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  # nextcloud autosync
  systemd.user.services.nextcloud-autosync = {
    Unit.Description = "Nextcloud Autosync";
    Service = {
      Type = "oneshot";
      EnvironmentFile = "/run/agenix/nextcloud-autosync";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/cloud";
      ExecStart = "${pkgs.nextcloud-client}/bin/nextcloudcmd -h --non-interactive %h/cloud https://thegoose.cloud";
      TimeoutStopSec = "180";
      KillSignal = "SIGINT";
    };
  };
  systemd.user.timers.nextcloud-autosync = {
    Unit.Description = "Run Nextcloud Autosync half-hourly";
    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "30min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
  systemd.user.startServices = "sd-switch";

  # bridge for the bitwarden browser extension
  home.file.".mozilla/native-messaging-hosts/com.8bit.bitwarden.json".text = builtins.toJSON {
    name = "com.8bit.bitwarden";
    description = "Bitwarden desktop <-> browser bridge";
    path = "/etc/profiles/per-user/skybound/bin/bitwarden";
    type = "stdio";
    allowed_extensions = [ "{446900e4-71c2-419f-a6a7-df9c091e268b}" ];
  };

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        copyous.extensionUuid
        pkgs.gnomeExtensions.gsconnect.extensionUuid
        pkgs.gnomeExtensions.unblank.extensionUuid
      ];
      favorite-apps = [
        "zen-twilight.desktop"
        "com.mitchellh.ghostty.desktop"
      ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
      switch-applications = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;
      switch-applications-backward = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;
    };

    "org/gnome/shell/extensions/copyous" = {
      open-clipboard-dialog-shortcut = [ "<Super>v" ];
      toggle-incognito-mode-shortcut = [ "<Control><Super>v" ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-show-weekday = true;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/calendar".show-weekdate = true;
    "org/gnome/desktop/datetime".automatic-timezone = true;
    "org/gnome/system/location".enabled = true;

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${wallpaper}";
      picture-uri-dark = "file://${wallpaper}";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-from = 20.0;
      night-light-schedule-to = 6.0;
    };

    "org/gnome/desktop/wm/keybindings".close = [
      "<Super>q"
      "<Alt>F4"
    ];

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
      www = [ "<Super>w" ];
      home = [ "<Super>e" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Open terminal";
      command = "ghostty";
      binding = "<Super>t";
    };
  };
}
