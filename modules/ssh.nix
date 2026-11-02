{ ... }:

{
  age.secrets.ssh-config = {
    rekeyFile = ../secrets/ssh-config.age;
    owner = "skybound";
  };
}