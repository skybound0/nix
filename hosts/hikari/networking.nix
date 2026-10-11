{ config, ... }:

{
  networking.hostName = "hikari";
  networking.nftables.enable = true;
  networking.useNetworkd = true;

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" "--operator=skybound" ];
  };

  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
