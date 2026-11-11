{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    modules.hardware.nvidia = {
      enable = lib.mkEnableOption "Nvidia drivers and configuration.";
    };
  };

  config = lib.mkIf config.modules.hardware.nvidia.enable {
    # --- Driver & Graphics Support ---
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages =
        let
          dxvk-nvapi-reflex-layer = pkgs.stdenv.mkDerivation {
            pname = "dxvk-nvapi-reflex";
            version = "0.9.3";

            src = pkgs.fetchurl {
              url = "https://github.com/jp7677/dxvk-nvapi/releases/download/v0.9.3/dxvk-nvapi-v0.9.3.tar.gz";
              sha256 = "284033c38e463ba31d40466d650d0c411df6f64bbf8ed3d19c9ca0cadf31dfd3";
            };

            sourceRoot = ".";

            installPhase = ''
              mkdir -p $out/lib $out/share/vulkan/implicit_layer.d

              cp layer/libdxvk_nvapi_vkreflex_layer.so $out/lib/
              cp layer/VkLayer_DXVK_NVAPI_reflex.json $out/share/vulkan/implicit_layer.d/

              sed -i "s|\./libdxvk_nvapi_vkreflex_layer\.so|$out/lib/libdxvk_nvapi_vkreflex_layer.so|g" $out/share/vulkan/implicit_layer.d/VkLayer_DXVK_NVAPI_reflex.json
            '';
          };
        in
        [
          dxvk-nvapi-reflex-layer
          pkgs.nvidia-vaapi-driver
        ];
    };

    # --- Nvidia Blackwell Configuration ---
    hardware.nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      nvidiaSettings = false;
    };

    boot.extraModprobeConfig = ''
      options nvidia NVreg_InitializeSystemMemoryAllocations=0
      options nvidia NVreg_TemporaryFilePath=/var/tmp
    '';

    # --- Session & Wayland Variables ---
    environment.sessionVariables = {
      NVIDIA_VARIANT = "open";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
      __GL_SHADER_DISK_CACHE_SIZE = "42949672960"; # 40GB in bytes
      DXVK_NVAPI_VKREFLEX = "1";
      PROTON_ENABLE_NVAPI = "1";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      NVD_BACKEND = "direct";
    };

    # --- Utils ---
    environment.systemPackages = with pkgs; [
      nvtopPackages.nvidia
    ];
  };
}
