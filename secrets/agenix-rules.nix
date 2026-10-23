let
  skybound-nozomi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6DhHnTh9Ps7hxGNifJGYaS1CWcBoxFsyapt2q9a4au";
  skybound-hikari = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVfB/num43zHbHkmY7ilhxUUqTQ4d8afR1G6vXuqkBT";
  skybound = [ skybound-nozomi skybound-hikari ];
  users = skybound ++ [];

  nozomi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOp398vRbxzloxBOMzbSaTv/eAAEe3NmTaBuqX0dddr";
  hikari = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSoO7MATbrHstBnW3VkmF7xoFykLf1NzaWNfVYCsoFY";
  systems = [ nozomi hikari ];
in
{
  "nextcloud.age".publicKeys = skybound ++ systems;
}
