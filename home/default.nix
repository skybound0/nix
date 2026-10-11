{ ... }:

{
  imports = [
    ./common.nix
    ./config.nix
    ./packages.nix
    ../modules/nautilus-taildrop.nix
  ];
}
