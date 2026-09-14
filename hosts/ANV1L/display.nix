{ ... }:

{
  home-manager.users.skill = {
    wayland.windowManager.hyprland.configType = "lua";
    xdg.configFile."hypr-host/host.lua".text = ''
      hl.config({
        render = {
          direct_scanout = true,
          cm_auto_hdr = 1
        },
        misc = {
          vrr = 2
        }
      })

      hl.window_rule({
          match = { class = "^(steam_app_\\d+)$" },
          workspace = "1"
      })
    '';
  };

  programs.dms-greeter = {
    enable = true;
    compositor.customConfig = ''
      // --- Left Vertical (DP-1) ---
      output "DP-1" {
          mode "1920x1080@60"
          position x=0 y=1210
          transform "270"
          scale 1.0
      }

      // --- Center Ultrawide (DP-3) ---
      output "DP-3" {
          mode "3440x1440@175"
          position x=1080 y=1440
          scale 1.0
      }

      // --- Top Center (DP-2) ---
      output "DP-2" {
          mode "2560x1440@165"
          position x=1520 y=0
          scale 1.0
      }

      // --- Right Vertical (HDMI-A-1) ---
      output "HDMI-A-1" {
          mode "1920x1080@60"
          position x=4520 y=1210
          transform "90"
          scale 1.0
      }

      hotkey-overlay {
          skip-at-startup
      }
    '';
  };

  environment.sessionVariables = {
    PROTON_WAYLAND_MONITOR = "DP-3";
  };
}
