{ ... }:

{
  networking.hostName = "hikari";
  networking.useNetworkd = true;

  services.tailscale.extraUpFlags = [ "--ssh" ];
}
