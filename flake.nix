{
  description = "skybound's nix configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    openterface-qt.url = "github:TechxArtisanStudio/Openterface_QT";
    mimick = {
      url = "file+https://raw.githubusercontent.com/skybound0/nixpkgs/d750adc8418971742153245012afa7df1888e37f/pkgs/by-name/mi/mimick/package.nix";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      agenix,
      agenix-rekey,
      lanzaboote,
      catppuccin,
      zen-browser,
      openterface-qt,
      mimick,
      ...
    }:
    let
      # shared by every host; per-host modules are added below
      commonModules = [
        { nixpkgs.overlays = [ self.overlays.default ]; }
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        agenix-rekey.nixosModules.default
        { environment.systemPackages = [ agenix-rekey.packages.x86_64-linux.default ]; }
      ];
    in
    {
      overlays.default = final: prev: {
        mimick = final.callPackage mimick { };
      };

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
      };

      nixosConfigurations.nozomi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [
          ./hosts/nozomi
          nixos-hardware.nixosModules.framework-13-7040-amd
          lanzaboote.nixosModules.lanzaboote
          catppuccin.nixosModules.catppuccin
          openterface-qt.nixosModules.openterface
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.skybound = {
              imports = [
                ./home
                catppuccin.homeModules.catppuccin
                zen-browser.homeModules.twilight
              ];
            };
          }
        ];
      };

      nixosConfigurations.hikari = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [
          ./hosts/hikari
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.skybound = {
              imports = [
                ./home/server.nix
                catppuccin.homeModules.catppuccin
              ];
            };
          }
        ];
      };
    };
}
