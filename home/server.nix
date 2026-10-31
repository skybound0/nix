{ ... }:

{
  imports = [
    ./common.nix
  ];

  # save ssh-agent identities for a lil bit
  services.ssh-agent.enable = true;
  services.ssh-agent.defaultMaximumIdentityLifetime = 28800;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*".AddKeysToAgent = "yes";
  };
}
