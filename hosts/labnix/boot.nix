{ ... }:

{
  # ESP is shared with Windows 11 and only 548 MiB, so keep few generations.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  system.nixos.label = "26.11";
}
