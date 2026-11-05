{ ... }:

{
  networking.hostName = "nozomi";

  boot.initrd.systemd.network.wait-online.enable = false;
}
