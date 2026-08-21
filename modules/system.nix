{ pkgs, ... }:

{
  users.users.skybound = {
    isNormalUser = true;
    description = "skybound";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    shell = pkgs.fish;
  };

  # Registers fish in /etc/shells; per-user fish config lives in home/config.nix.
  programs.fish.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
