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
    ./nix-server.nix
    ./services.nix
    ../../modules
  ];

  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKfedV5mWR4shBFHteYBfMybNWvzIGfp6bqJv5ky4eaz";

  time.timeZone = lib.mkForce null;

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

  # DO NOT CHANGE
  system.stateVersion = "26.11";
}
