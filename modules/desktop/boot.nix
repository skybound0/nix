{ pkgs, lib, ... }:

{
  # lanzaboote
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = lib.mkDefault 5;
    settings.editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "nfs" ];

  environment.systemPackages = [ pkgs.sbctl ];

  system.nixos.label = "26.11";
}
