{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # gnome extensions
    gnomeExtensions.gsconnect
    gnomeExtensions.unblank

    # desktop apps
    vesktop
    beeper
    vscode-fhs
    freecad
    bambu-studio
    parsec-bin
    github-cli
    inkscape
    zoom-us
    kicad
    gimp-with-plugins
    steam
    mimick

    # tidal-hifi's chromium sandbox breaks the UI on launch
    (symlinkJoin {
      name = "tidal-hifi-wrapped";
      paths = [ tidal-hifi ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/tidal-hifi --add-flags "--no-sandbox"
      '';
    })

    # utilities
    appimage-run
    usbutils
  ];
}
