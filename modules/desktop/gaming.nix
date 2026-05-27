{ pkgs, lib, config, ... }:

let
  mangoConfig = "position=top-left,toggle_hud=bracketright,fps,frametime,cpu_temp,gpu_temp,vram,ram,core_bars,no_display,fps_limit=173,fps_limit_method=late";

  # core optimizations
  baseEnv = ''
    export PROTON_ENABLE_NVAPI=1
    export DXVK_ENABLE_NVAPI=1
    export DXVK_CONFIG="dxvk.maxFrameLatency=1"
    export PROTON_LOCAL_SHADER_CACHE=1
    export PROTON_USE_NTSYNC=1
    export PROTON_DLSS_UPGRADE=1
  '';

  # Wayland and HDR configuration
  waylandHdrEnv = ''
    export SDL_VIDEODRIVER=wayland
    export SDL_VIDEO_DRIVER=wayland
    export DXVK_HDR=1
    export PROTON_ENABLE_HDR=1
    export PROTON_ENABLE_WAYLAND=1
    export ENABLE_HDR_WSI=1
    export VKD3D_CONFIG="hdr,dxr,dxr11,frame_latency=1"
  '';
in
{
  options = {
    modules.desktop.gaming = {
      enable = lib.mkEnableOption "Gaming related configurations";
    };
  };

  config = lib.mkIf config.modules.desktop.gaming.enable {
    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 9;
        };
        cpu = {
          pin_cores = "0-7,16-23";
        };
        gpu = {
          apply_gpu_optimizations = "accept-responsibility";
          gpu_device = 0;
          nv_powermizer_mode = 1;
        };
      };
    };

    # Enable Gamescope via NixOS module to properly handle capabilities
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      platformOptimizations.enable = true;
      gamescopeSession.enable = false;
      package = pkgs.steam.override {
        extraPkgs = pkgs: [ pkgs.hidapi ];
        extraEnv = {
          WINE_CPU_TOPOLOGY = "16:0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23";
          MANGOHUD_CONFIG = mangoConfig;
          PROTON_ENABLE_NVAPI = "1";
          DXVK_ENABLE_NVAPI = "1";
          PROTON_LOCAL_SHADER_CACHE = "1";
          PROTON_USE_NTSYNC = "1";
          PROTON_DLSS_UPGRADE = "1";
        };
      };
    };

    nix.settings = {
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-3:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
    };

    environment.systemPackages = with pkgs; [
      mangohud
      heroic

      # Helper for standard Wayland gaming
      (writeShellScriptBin "gs" ''
        ${baseEnv}
        ${waylandHdrEnv}
        export MANGOHUD_CONFIG="${mangoConfig}"

        exec gamemoderun mangohud "$@"
      '')

      # Fallback without forced HDR/Wayland overrides
      (writeShellScriptBin "gs2" ''
        ${baseEnv}
        export VKD3D_CONFIG="dxr,dxr11,frame_latency=1"
        export MANGOHUD_CONFIG="${mangoConfig}"

        exec gamemoderun mangohud "$@"
      '')

      # Gamescope wrapper
      (writeShellScriptBin "gs3" ''
        ${baseEnv}
        export DXVK_HDR=1
        export ENABLE_HDR_WSI=1
        export PROTON_ENABLE_HDR=1
        export VKD3D_CONFIG="hdr,dxr,dxr11,frame_latency=1"
        export MANGOHUD_CONFIG="${mangoConfig}"

        # NVIDIA explicit Wayland fixes
        export WLR_DRM_NO_MODIFIERS=1
        export WLR_NO_HARDWARE_CURSORS=1

        exec gamescope --rt --immediate-flips --adaptive-sync -W 3440 -H 1440 -f -e --hdr-enabled --force-grab-cursor -- gamemoderun mangohud "$@"
      '')

      # The Nuclear Option Gamescope Wrapper
      (writeShellScriptBin "gs4" ''

        export VKD3D_CONFIG="dxr,dxr11,frame_latency=1" # No HDR flag
        export MANGOHUD_CONFIG="${mangoConfig}"

        # NVIDIA Nested Compositor Fixes
        export WLR_RENDERER=vulkan
        export WLR_DRM_NO_MODIFIERS=1
        export WLR_NO_HARDWARE_CURSORS=1
        export XWAYLAND_NO_GLAMOR=1

        # Launch Gamescope strictly in SDR
        exec gamescope -- gamemoderun mangohud "$@"
      '')

      # Helper specifically for Flatpak gaming (No host MangoHud injection)
      (writeShellScriptBin "gs-flatpak" ''
        ${baseEnv}
        ${waylandHdrEnv}

        exec gamemoderun "$@"
      '')
    ];
  };
}
