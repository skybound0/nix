{ ... }:

{
  imports = [
    ./networking.nix
    ./nextcloud.nix
    ./packages.nix
    ./secrets.nix
    ./services.nix
    ./system.nix
  ];
}
