{ ... }:

{
  imports = [
    ./networking.nix
    ./nextcloud.nix
    ./packages.nix
    ./secrets.nix
    ./services.nix
    ./ssh.nix
    ./system.nix
  ];
}
