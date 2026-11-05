{ ... }:

{
  imports = [
    ./networking.nix
    ./nextcloud.nix
    ./packages.nix
    ./pin-login.nix
    ./secrets.nix
    ./services.nix
    ./ssh.nix
    ./system.nix
  ];
}
