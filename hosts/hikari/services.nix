{ ... }:

{
  # for TrueNAS virtualization
  services.qemuGuest.enable = true;

  # allow freed zvol space to be returned to pool
  services.fstrim.enable = true;

  services.openssh.settings = {
    PermitRootLogin = "no";
  };

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  users.users.skybound.extraGroups = [ "docker" ];

  programs.nix-ld.enable = true;
}
