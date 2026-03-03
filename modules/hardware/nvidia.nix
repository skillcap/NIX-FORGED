{ config, pkgs, lib, ... }:

{
  options = {
    modules.hardware.nvidia = {
      enable = lib.mkEnableOption "Nvidia drivers and configuration.";
    };
  };

  config = lib.mkIf config.modules.hardware.nvidia.enable {
    # --- Driver & Graphics Support ---
    services.xserver.videoDrivers = ["nvidia"];
    hardware.graphics.enable = true;

    # --- Nvidia Blackwell Configuration ---
    hardware.nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
      powerManagement.enable = true;
      nvidiaSettings = true;
      powerManagement.finegrained = false; # maybe remove for laptops
    };
    boot.extraModprobeConfig = "options nvidia NVreg_EnableGpuFirmware=1";

    # --- Session & Wayland Variables ---
    environment.sessionVariables = {
      NVIDIA_VARIANT = "open";
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
      __GL_SHADER_DISK_CACHE_SIZE = "42949672960"; # 40GB in bytes
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      NVD_BACKEND = "direct";
    };

    # --- Utils ---
    environment.systemPackages = with pkgs; [
      nvtopPackages.nvidia # Monitoring
    ];
  };
}
