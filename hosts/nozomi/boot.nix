{ pkgs, lib, ... }:

{
  # lanzaboote
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    # smol because esp is shared with windows
    configurationLimit = 3;
    settings.editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "nfs" ];

  # needed for tpm2 luks unlock
  boot.initrd.systemd.enable = true;

  environment.systemPackages = [ pkgs.sbctl ];

  system.nixos.label = "26.11";
}
