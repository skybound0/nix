{ pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    github-cli
    btop
    tmux
    jq
    ripgrep
    fd
  ];
}
