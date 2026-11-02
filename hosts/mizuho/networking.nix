{ ... }:

{
  networking.hostName = "mizuho";
  networking.networkmanager.enable = true;

  systemd.network.wait-online.enable = false;
}
