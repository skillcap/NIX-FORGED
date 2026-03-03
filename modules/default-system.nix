{ lib, ... }:

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

  modules.hardware = {
    audio.enable = lib.mkDefault true;
    nvidia.enable = lib.mkDefault true;
    RTX-5090-OC.enable = lib.mkDefault false;
  };
}
