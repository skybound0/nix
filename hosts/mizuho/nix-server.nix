{ config, lib, ... }:

{
  nix.sshServe = {
    enable = true;
    protocol = "ssh-ng";
    write = true;
    trusted = true;
    keys = [
      # root@nozomi
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOp398vRbxzloxBOMzbSaTv/eAAEe3NmTaBuqX0dddr"
    ];
  };

  nix.settings = {
    max-jobs = 4;
    cores = 6;
  };

  nix.daemonCPUSchedPolicy = "batch";

  systemd.slices.nix-builds.sliceConfig = {
    CPUWeight = 20;
    MemoryHigh = "20G";
    MemoryMax = "24G";
    MemorySwapMax = "4G";
  };

  systemd.services.nix-daemon.serviceConfig.Slice = "nix-builds.slice";

  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ config.age.secrets.nix-cache-key.path ];
    settings.priority = 30;
  };

  age.secrets.nix-cache-key = {
    rekeyFile = ../../secrets/nix-cache-key.age;
    generator.script =
      { pkgs, file, ... }:
      let
        nix = "${lib.getExe pkgs.nix} --extra-experimental-features nix-command";
      in
      ''
        priv=$(${nix} key generate-secret --key-name mizuho-1)
        ${nix} key convert-secret-to-public <<< "$priv" \
          > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
        echo "$priv"
      '';
  };
}
