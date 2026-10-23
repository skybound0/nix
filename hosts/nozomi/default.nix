{ 
  lib,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./audio.nix
    ./boot.nix
    ./graphical.nix
    ./networking.nix
    ./services.nix
    ../../modules
  ];

  time.timeZone = lib.mkForce null; 
  # for matching windows rtc
  time.hardwareClockInLocalTime = true;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  fileSystems."/mnt/labsys" = {
    device = "100.111.112.89:/mnt/Primary/skybound";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "nfsvers=4" ];
  };

  # DO NOT CHANGE
  system.stateVersion = "26.05";
}
