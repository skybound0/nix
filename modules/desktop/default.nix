{ lib, ... }:

{
  imports = [
    ./audio.nix
    ./boot.nix
    ./gnome.nix
    ./services.nix
  ];

  networking.networkmanager.enable = true;
  systemd.network.wait-online.enable = false;

  time.timeZone = lib.mkForce null;
}
