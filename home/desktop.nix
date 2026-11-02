{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # rocm build
    pkgsRocm.blender

    darktable
    krita
    kdePackages.kdenlive
  ];
}
