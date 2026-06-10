{ ... }:

{
  home-manager.users.skill = {
    xdg.configFile."hypr-host/host.conf".text = ''
      # ==============================
      # HYPRLAND MONITOR CONFIGURATION
      # ==============================
      # Single 4K Laptop Display
      monitor=eDP-1, 3840x2160@60, 0x0, 1.5

      workspace = 1, monitor:eDP-1, default:true

      render {
          direct_scanout = 3
          cm_fs_passthrough = 1
      }

      misc {
          vrr = 2
          vfr = true
      }
    '';
  };
}
