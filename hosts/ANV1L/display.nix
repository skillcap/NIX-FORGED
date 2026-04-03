{ config, pkgs, ... }:

{
  home-manager.users.skill = {
    xdg.configFile."hypr-host/host.conf".text = ''
      # ==============================
      # HYPRLAND MONITOR CONFIGURATION
      # ==============================
      monitor=DP-1, 1920x1080@60, 0x1210, 1, transform, 3
      monitor=DP-2, 2560x1440@165, 1520x0, 1
      monitor=DP-3, 3440x1440@175, 1080x1440, 1, bitdepth, 10, cm, hdredid, sdrbrightness, 1.2, sdrsaturation, 1.15
      monitor=HDMI-A-1, 1920x1080@60, 4520x1210, 1, transform, 1

      workspace = 1, monitor:DP-3, default:true
      workspace = 2, monitor:DP-1, default:true
      workspace = 3, monitor:DP-2, default:true
      workspace = 4, monitor:HDMI-A-1, default:true

      render {
          direct_scanout = 3
          cm_fs_passthrough = 1
      }

      misc {
          vrr = 2
          vfr = true
      }

      windowrule {
          name = steam_games_dp3
          match:class = ^(steam_app_\d+)$
          workspace = 1
      }
    '';
  };

  programs.dank-material-shell.greeter.compositor.customConfig = ''
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
  environment.sessionVariables = {
    PROTON_WAYLAND_MONITOR = "DP-3";
  };
}
