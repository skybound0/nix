{ ... }:

{
  imports = [
    ./hardware.nix
    ./audio.nix
    ./boot.nix
    ./graphical.nix
    ./networking.nix
    ../../modules
  ];

  time.timeZone = "America/Chicago";
  # For matching Windows RTC
  time.hardwareClockInLocalTime = true;

  i18n.defaultLocale = "en_US.UTF-8";
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

  documentation.nixos.enable = false;

  # Set at install time. Do not bump without reading the release notes.
  system.stateVersion = "26.05";
}
