{ ... }:

{
  imports = [
    ./config.nix
    ./packages.nix
    ../modules/nautilus-taildrop.nix
  ];
}
