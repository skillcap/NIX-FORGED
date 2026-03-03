{ lib, ... }:

{
  imports = [
    ./core/boot.nix
    ./core/fonts.nix
    ./core/system-cli.nix

    ./desktop/gaming.nix
    ./desktop/hyprland-system.nix

    ./development/podman.nix

  ];

  modules.core = {
    boot.enable = lib.mkDefault true;
    boot.nvidia.enable = lib.mkDefault true;
    fonts.enable = lib.mkDefault true;
    system-cli.enable = lib.mkDefault true;
  };

  modules.desktop = {
    gaming.enable = lib.mkDefault true;
    hyprland-system.enable = lib.mkDefault true;
  };

  modules.development = {
    podman.enable = lib.mkDefault true;
  };
}
