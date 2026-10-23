{ pkgs, ... }:

{
  users.users.skybound = {
    isNormalUser = true;
    description = "skybound";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  documentation.nixos.enable = false;

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
