{ pkgs, inputs, lib, config, ... }:

{
  options = {
    modules.desktop.hyprland-system = {
      enable = lib.mkEnableOption "System level configuration for Hyprland";
    };
  };

  config = lib.mkIf config.modules.desktop.hyprland-system.enable {
    # --- Desktop ---
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    programs.dux-shell = {
      enable = true;
      quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };

    programs.dux-search = {
      enable = true;
    };

    programs.dux-files = {
      enable = true;
      systemd.enable = true;
      portal.enable = true;
    };
    xdg.portal.config.common."org.freedesktop.impl.portal.FileChooser" = [ "dfiles" ];

    # DMS Greeter
    services.displayManager.defaultSession = "hyprland-uwsm";
    programs.dms-greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/skill";
      # Display configuration moved to hosts/<hostname>/display.nix
    };

    programs.niri.enable = true; # for DMS Greeter
    programs.nix-ld.enable = true;

    programs.dux-calendar = {
      enable = true;
      systemd.enable = true;
    };

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = false;

    environment.systemPackages = with pkgs; [
      vulkan-hdr-layer-kwin6
    ];
  };
}
