{ config, ... }:

{
  age.rekey = {
    masterIdentities = [
      {
        # skybound@nozomi
        identity = "/home/skybound/.ssh/id_ed25519";
        pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6DhHnTh9Ps7hxGNifJGYaS1CWcBoxFsyapt2q9a4au";
      }
      ../secrets/identities/o1.pub
      ../secrets/identities/o2.pub
    ];
    # skybound@hikari
    extraEncryptionPubkeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVfB/num43zHbHkmY7ilhxUUqTQ4d8afR1G6vXuqkBT"
    ];
    storageMode = "local";
    localStorageDir = ../. + "/secrets/rekeyed/${config.networking.hostName}";
  };
}
