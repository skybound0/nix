{ ... }:

{
  imports = [
    ./hardware.nix
    ./boot.nix
    ./encryption.nix
    ./networking.nix
    ./nix-remote.nix
    ./services.nix
    ../../modules
    ../../modules/desktop
  ];

  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOp398vRbxzloxBOMzbSaTv/eAAEe3NmTaBuqX0dddr";

  # for matching windows rtc
  time.hardwareClockInLocalTime = true;

  # fileSystems."/mnt/labsys" = {
  #   device = "100.111.112.89:/mnt/Primary/skybound";
  #   fsType = "nfs";
  #   options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "nfsvers=4" ];
  # };

  # DO NOT CHANGE
  system.stateVersion = "26.05";
}
