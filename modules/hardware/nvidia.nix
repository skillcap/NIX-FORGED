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
    services.xserver.deviceSection = ''
      Option "Coolbits" "31"
    '';

    hardware.graphics = {
      enable = true;
      extraPackages = let
        dxvk-nvapi-reflex-layer = pkgs.stdenv.mkDerivation rec {
          pname = "dxvk-nvapi-reflex";
          version = "0.9.1";

          src = pkgs.fetchurl {
            url = "https://github.com/jp7677/dxvk-nvapi/releases/download/v${version}/dxvk-nvapi-v${version}.tar.gz";
            hash = "sha256-ZIIsn3QAV+whfEgEJPKL1RmnzpM2HGz7pLP6e9mJUCs=";
          };

          sourceRoot = ".";

          installPhase = ''
            mkdir -p $out/lib $out/share/vulkan/implicit_layer.d

            cp layer/libdxvk_nvapi_vkreflex_layer.so $out/lib/
            cp layer/VkLayer_DXVK_NVAPI_reflex.json $out/share/vulkan/implicit_layer.d/

            sed -i "s|\./libdxvk_nvapi_vkreflex_layer\.so|$out/lib/libdxvk_nvapi_vkreflex_layer.so|g" $out/share/vulkan/implicit_layer.d/VkLayer_DXVK_NVAPI_reflex.json
          '';
        };
      in [
        dxvk-nvapi-reflex-layer
      ];
    };

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
