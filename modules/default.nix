{ ... }:

{
  imports = [
    ./packages.nix
    ./services.nix
    ./system.nix
  ];

  # nautilus-taildrop.nix is a Home Manager module, not a NixOS one, so it
  # is imported from ../home/default.nix instead of here.
}
