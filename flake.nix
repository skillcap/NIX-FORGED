{
  description = "ANV1L NixOS Configuration";

  inputs = {
    # TEMPORARY PIN: the Nix registry visible on these machines resolves
    # nixos-unstable to f4a03c0 (2026-11-07), whose rusty-man expression
    # is broken under the new cargo hook. The fix landed one day later:
    # https://github.com/NixOS/nixpkgs/commit/492f34b4a3e08b8627fc370ae100cc14a67e50d5
    # Remove this pin (back to "nixos/nixpkgs/nixos-unstable") once
    # `nix flake update nixpkgs` can reach commits newer than 2026-11-07.
    nixpkgs.url = "github:nixos/nixpkgs/492f34b4a3e08b8627fc370ae100cc14a67e50d5";
    disko.url = "github:nix-community/disko";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
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
    dank-greeter.url = "github:AvengeMedia/dank-greeter";
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvidia-oc-src = {
      url = "github:Dreaming-Codes/nvidia_oc";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      lanzaboote,
      zen-browser,
      nix-gaming,
      quickshell,
      dms,
      dank-greeter,
      sops-nix,
      disko,
      ...
    }@inputs:
    {
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
          dank-greeter.nixosModules.default

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
          dank-greeter.nixosModules.default

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
