{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # gnome extensions
    gnomeExtensions.gsconnect

    # desktop apps
    vesktop
    beeper
    vscode-fhs
    freecad
    autodesk-fusion
    bambu-studio
    bitwarden-desktop
    parsec-bin
    inkscape
    zoom-us
    kicad
    gimp-with-plugins
    steam
    mission-planner
    libreoffice
    hunspell
    hunspellDicts.en_US
    tigervnc
    cider-2
    obs-studio

    # cloud
    nextcloud-talk-desktop
    mimick

    # tidal-hifi's chromium sandbox breaks the UI on launch
    # (symlinkJoin {
    #   name = "tidal-hifi-wrapped";
    #   paths = [ tidal-hifi ];
    #   buildInputs = [ makeWrapper ];
    #   postBuild = ''
    #     wrapProgram $out/bin/tidal-hifi --add-flags "--no-sandbox"
    #   '';
    # })

    # utilities
    appimage-run
    usbutils
  ]
  ++ lib.optional config.my.desktop.unblank pkgs.gnomeExtensions.unblank
  ++ lib.optional config.my.desktop.multiMonitorBar pkgs.gnomeExtensions.multi-monitor-bar;
}
