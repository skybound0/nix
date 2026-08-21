{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    wget
    htop
    fastfetch
    tree
    dnsutils # dig, nslookup
  ];
}
