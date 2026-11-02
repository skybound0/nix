{ lib, ... }:

{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "mizuho";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      sshUser = "nix-ssh";
      sshKey = "/etc/ssh/ssh_host_ed25519_key";
      maxJobs = 4;
      speedFactor = 4;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    }
  ];

  programs.ssh.knownHosts.mizuho.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKfedV5mWR4shBFHteYBfMybNWvzIGfp6bqJv5ky4eaz";

  programs.ssh.extraConfig = ''
    Host mizuho
      ConnectTimeout 5
  '';

  nix.settings = {
    builders-use-substitutes = true;
    connect-timeout = 5;
    fallback = true;

    substituters = [ "http://mizuho:5000" ];
    trusted-public-keys = [ (lib.fileContents ../../secrets/nix-cache-key.pub) ];
  };
}
