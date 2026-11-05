{ pkgs, ... }:

{
  home.packages = [ pkgs.hylki ];

  # send with hylki on nautilus
  home.file.".local/share/nautilus-python/extensions/hylki-nautilus.py".source =
    "${pkgs.hylki.src}/data/nautilus/hylki-nautilus.py";
}
