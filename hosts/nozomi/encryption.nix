{ ... }:

{
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-partuuid/e4b2b995-7417-4560-84fc-ca0de6c77f76";
    allowDiscards = true;
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
}
