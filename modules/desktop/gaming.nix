{ pkgs, lib, config, ... }:


# need to generalize this later
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
      };
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      platformOptimizations.enable = true;
      gamescopeSession.enable = false;
      package = pkgs.steam.override {
        extraEnv = {
          WINE_CPU_TOPOLOGY = "16:0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23";
          VKD3D_CONFIG = "dxr,dxr11";
          MANGOHUD_CONFIG = "position=top-right,toggle_hud=bracketright,fps,frametime,cpu_temp,gpu_temp,vram,ram,core_bars,fps_limit=173,no_display";
        };
      };
    };

    # --- Gaming Cache ---
    nix.settings = {
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-3:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
    };

    environment.systemPackages = with pkgs; [
      mangohud
      (writeShellScriptBin "gs" ''
        export SDL_VIDEODRIVER=wayland
        export SDL_VIDEO_DRIVER=wayland
        export DXVK_HDR=1
        export PROTON_ENABLE_HDR=1
        export PROTON_ENABLE_WAYLAND=1
        export ENABLE_HDR_WSI=1
        export VKD3D_CONFIG="hdr,dxr,dxr11"

        exec gamemoderun mangohud "$@"
      '')
      (writeShellScriptBin "gs2" ''
        exec gamemoderun mangohud "$@"
      '')
    ];
  };
}
