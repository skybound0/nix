{ ... }:

{
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [ "nfs" ];

  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200" ];
}
