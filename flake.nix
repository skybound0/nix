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
    hylki = {
      url = "github:clementpoiret/hylki-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      hylki,
      mimick,
      ...
    }:
    let
      commonModules = [
        { nixpkgs.overlays = [ self.overlays.default ]; }
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        agenix-rekey.nixosModules.default
        { environment.systemPackages = [ agenix-rekey.packages.x86_64-linux.default ]; }
      ];

      mkDesktop =
        name: hardwareModules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            commonModules
            ++ hardwareModules
            ++ [
              ./hosts/${name}
              lanzaboote.nixosModules.lanzaboote
              catppuccin.nixosModules.catppuccin
              openterface-qt.nixosModules.openterface
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.skybound.imports = [
                  ./home
                  ./hosts/${name}/home.nix
                  catppuccin.homeModules.catppuccin
                  zen-browser.homeModules.twilight
                ];
              }
            ];
        };
    in
    {
      overlays.default = final: prev: {
        mimick = final.callPackage mimick { };
        hylki = hylki.packages.${final.stdenv.hostPlatform.system}.default;
        autodesk-fusion = final.callPackage ./pkgs/autodesk-fusion/package.nix { };
        lockscreen-fingerprint = final.callPackage ./pkgs/lockscreen-fingerprint/package.nix { };
        # nixpkgs only has unblank v40 for shell v<=49, need to replace after it is updated
        gnomeExtensions = prev.gnomeExtensions // {
          unblank = prev.gnomeExtensions.unblank.overrideAttrs (_: {
            version = "41";
            src = final.fetchzip {
              url = "https://extensions.gnome.org/extension-data/unblanksun.wxggmail.com.v41.shell-extension.zip";
              hash = "sha256-hQeUGEdOHg6aJp8Dph3U/XaV3msyZZSxrJbTpxeDwKo=";
              stripRoot = false;
            };
          });
        };
      };

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
      };

      nixosConfigurations.nozomi = mkDesktop "nozomi" [
        nixos-hardware.nixosModules.framework-13-7040-amd
      ];

      nixosConfigurations.mizuho = mkDesktop "mizuho" [
        nixos-hardware.nixosModules.common-pc
        nixos-hardware.nixosModules.common-pc-ssd
        nixos-hardware.nixosModules.common-cpu-intel-cpu-only
        nixos-hardware.nixosModules.common-gpu-amd
      ];

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
