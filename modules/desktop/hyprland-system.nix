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

    # Dank Material Shell Ecosystem
    programs.dms-shell = {
      enable = true;
      quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };

    # DankSearch
    programs.dsearch.enable = true;

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

    # Calendar Backend & Integration Services
    services.gnome.evolution-data-server.enable = true;
    services.gnome.gnome-online-accounts.enable = true;
    programs.dconf.enable = true;

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = false;

    environment.systemPackages = with pkgs; [
      dsearch
      vulkan-hdr-layer-kwin6
    ];
  };
}
