{ pkgs, inputs, lib, config, ... }:

{
  options = {
      modules.desktop.hyprland-system  = {
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

    # Dank Material Shell Ecosystem
    programs.dms-shell = {
      enable = true;
      quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      # Core features
      enableSystemMonitoring = true;
      enableVPN = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
    };

    # DankSearch
    programs.dsearch.enable = true;

    # DMS Greeter
    services.displayManager.defaultSession = "hyprland-uwsm";
    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/skill";
      # Display configuration moved to hosts/<hostname>/display.nix
    };

    programs.niri.enable = true; # for DMS Greeter

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

    environment.systemPackages = with pkgs; [
      inputs.dsearch.packages.${pkgs.system}.default
      vulkan-hdr-layer-kwin6
    ];
  };
}
