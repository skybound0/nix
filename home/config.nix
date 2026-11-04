{
  config,
  pkgs,
  lib,
  ...
}:

let
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
  options.my.desktop.wallpaper = lib.mkOption {
    type = lib.types.path;
    description = "desktop wallpaper";
  };

  options.my.desktop.unblank = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "keep the screen on while locked (unblank extension)";
  };

  config = {
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

    xdg.autostart = {
      enable = true;
      entries = [ "${pkgs.beeper}/share/applications/beepertexts.desktop" ];
    };

    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 11;
        maximize = true;

        keybind = [
          "ctrl+alt+w=close_surface"
          "ctrl+alt+h=goto_split:left"
          "ctrl+alt+j=goto_split:down"
          "ctrl+alt+k=goto_split:up"
          "ctrl+alt+l=goto_split:right"
        ]
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

    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          copyous.extensionUuid
          pkgs.gnomeExtensions.gsconnect.extensionUuid
        ]
        ++ lib.optional config.my.desktop.unblank pkgs.gnomeExtensions.unblank.extensionUuid;
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
        picture-uri = "file://${config.my.desktop.wallpaper}";
        picture-uri-dark = "file://${config.my.desktop.wallpaper}";
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
  };
}
