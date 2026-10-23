{ config, ... }:

{
  networking.nftables.enable = true;

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--operator=skybound" ];
  };

  # force tailscaled onto nftables directly
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
