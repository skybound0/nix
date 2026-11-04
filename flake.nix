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
        autodesk-fusion = final.callPackage ./pkgs/autodesk-fusion/package.nix { };
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
            home-manager.users.skybound =
              { pkgs, ... }:
              {
                imports = [
                  ./home
                  catppuccin.homeModules.catppuccin
                  zen-browser.homeModules.twilight
                ];
                my.desktop.wallpaper = pkgs.fetchurl {
                  name = "nozomi-wallpaper.png";
                  url = "https://thegoose.cloud/apps/files_sharing/publicpreview/KxE95nD6qKaEs2R?file=/&fileId=646&x=2256&y=1504&a=true&etag=a8774b83fbdae6cd3e1e6df1c8663408";
                  hash = "sha256-aoKHI9n02Gki1ISEyrWW1C/hRoqhmgr2BK6ugng7XjI=";
                };
                my.desktop.unblank = true;
              };
          }
        ];
      };

      nixosConfigurations.mizuho = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [
          ./hosts/mizuho
          nixos-hardware.nixosModules.common-pc
          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-cpu-intel-cpu-only
          nixos-hardware.nixosModules.common-gpu-amd
          lanzaboote.nixosModules.lanzaboote
          catppuccin.nixosModules.catppuccin
          openterface-qt.nixosModules.openterface
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.skybound =
              { pkgs, ... }:
              {
                imports = [
                  ./home
                  ./home/desktop.nix
                  catppuccin.homeModules.catppuccin
                  zen-browser.homeModules.twilight
                ];
                my.desktop.wallpaper = pkgs.fetchurl {
                  name = "mizuho-wallpaper-placeholder.png";
                  url = "https://thegoose.cloud/apps/files_sharing/publicpreview/ALzEd34YEMtXEpZ?file=/&fileId=808&x=2560&y=1440&a=true&etag=4dc76c354284bd329623b1701c23b9e1";
                  hash = "sha256-unOBq9bl2yinwnzSM2JHZVYsEXutkg+FsQNjmZb/9dI=";
                };
                my.desktop.unblank = false;
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
