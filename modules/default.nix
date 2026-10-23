{ ... }:

{
  imports = [
    ./networking.nix
    ./nextcloud.nix
    ./packages.nix
    ./services.nix
    ./system.nix
  ];
}
