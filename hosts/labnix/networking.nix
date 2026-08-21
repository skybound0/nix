{ config, ... }:

{
  networking.hostName = "labnix";
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--operator=skybound" ];
  };

  # Force tailscaled onto nftables directly rather than the iptables-compat
  # translation layer, which misbehaves on nftables-only systems.
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    # KDE Connect / GSConnect device discovery and transfer
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };

  # Don't block boot waiting on a network that may only come up via VPN.
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;
}
