let
  skybound = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6DhHnTh9Ps7hxGNifJGYaS1CWcBoxFsyapt2q9a4au";
  users = [ skybound ];

  nozomi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOp398vRbxzloxBOMzbSaTv/eAAEe3NmTaBuqX0dddr";
  systems = [ nozomi ];
in
{
  "nextcloud.age".publicKeys = users ++ systems;
}
