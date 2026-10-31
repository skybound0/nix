{ ... }:

{
  imports = [
    ./hardware.nix
    ./boot.nix
    ./networking.nix
    ./services.nix
    ../../modules
  ];

  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSoO7MATbrHstBnW3VkmF7xoFykLf1NzaWNfVYCsoFY";

  time.timeZone = "America/Los_Angeles";

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  # fileSystems."/mnt/labsys" = {
  #   device = "100.111.112.89:/mnt/Primary/skybound";
  #   fsType = "nfs";
  #   options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "nfsvers=4" ];
  # };

  # DO NOT CHANGE
  system.stateVersion = "26.11";
}
