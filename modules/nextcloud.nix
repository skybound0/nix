{ ... }:

{
  # secrets for home/nextcloud-autosync.nix
  age.secrets.nextcloud-autosync = {
    rekeyFile = ../secrets/nextcloud.age;
    owner = "skybound";
  };

  # keep the user manager running without a login so the sync timer works on headless
  users.users.skybound.linger = true;
}
