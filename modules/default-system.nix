{ lib, config, ... }:

{
  imports = [
    ./core/boot.nix
    ./core/fonts.nix
    ./core/system-cli.nix
    ./desktop/gaming.nix
    ./desktop/hyprland-system.nix
    ./development/podman.nix
    ./hardware/audio.nix
    ./hardware/nvidia.nix
    ./hardware/RTX-5090-OC.nix
  ];

  options.host.profile = lib.mkOption {
    type = lib.types.enum [ "desktop" "laptop" "server" ];
    default = "desktop";
    description = "The global hardware and software profile for this host.";
  };

  config = {
    modules.core = {
      boot = {
        enable = lib.mkDefault true;
        compileLocally = lib.mkDefault false;
        cpuVendor = lib.mkDefault "amd";
        cpuOptimization = lib.mkDefault "generic"; # "generic" "zen3" "zen4"
        hasNvidia = lib.mkDefault (config.host.profile != "server");
        largeMemory = lib.mkDefault (config.host.profile == "desktop" || config.host.profile == "server");
      };
      fonts.enable = lib.mkDefault (config.host.profile != "server");
      system-cli.enable = lib.mkDefault true;
    };

    modules.desktop = {
      gaming.enable = lib.mkDefault (config.host.profile != "server");
      hyprland-system.enable = lib.mkDefault (config.host.profile != "server");
    };

    modules.development = {
      podman.enable = lib.mkDefault true;
    };

    modules.hardware = {
      audio.enable = lib.mkDefault (config.host.profile != "server");
      nvidia.enable = lib.mkDefault (config.host.profile != "server");
      RTX-5090-OC.enable = lib.mkDefault false;
    };
  };
}
