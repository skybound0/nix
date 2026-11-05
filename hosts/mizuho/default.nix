{ ... }:

{
  imports = [
    ./hardware.nix
    ./graphical.nix
    ./networking.nix
    ./nix-server.nix
    ../../modules
    ../../modules/desktop
  ];

  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKfedV5mWR4shBFHteYBfMybNWvzIGfp6bqJv5ky4eaz";

  my.pinLogin.enable = true;

  # DO NOT CHANGE
  system.stateVersion = "26.11";
}
