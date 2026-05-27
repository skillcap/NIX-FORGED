{
  description = "ANV1L NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    sops-nix.url = "github:Mic92/sops-nix";
    qbz.url = "github:vicrodh/qbz";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    dms.url = "github:AvengeMedia/DankMaterialShell/stable";
    dsearch.url = "github:AvengeMedia/danksearch";
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # A very cool Nvidia OC tool written in Rust.
    nvidia-oc-src = {
        url = "github:Dreaming-Codes/nvidia_oc";
        flake = false;
      };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, zen-browser, nix-gaming, quickshell, dms, sops-nix, disko, ... }@inputs: {
    nixosConfigurations."ANV1L" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        ./hosts/ANV1L/default.nix

        home-manager.nixosModules.home-manager
        lanzaboote.nixosModules.lanzaboote
        nix-gaming.nixosModules.platformOptimizations
        sops-nix.nixosModules.sops
        dms.nixosModules.dank-material-shell
        dms.nixosModules.greeter

        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.skill = import ./home.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };

    nixosConfigurations."N0M4D" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        ./hosts/N0M4D/default.nix

        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        lanzaboote.nixosModules.lanzaboote
        nix-gaming.nixosModules.platformOptimizations
        sops-nix.nixosModules.sops
        dms.nixosModules.dank-material-shell
        dms.nixosModules.greeter

        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.skill = import ./home.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
