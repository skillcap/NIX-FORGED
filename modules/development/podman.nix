{ pkgs, lib, config, ... }:

{
  options = {
    modules.development.podman = {
      enable = lib.mkEnableOption "Container management engine.";
    };
  };

  config = lib.mkIf config.modules.development.podman.enable {
    virtualisation.containers.enable = true;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    environment.systemPackages = with pkgs; [
      podman-compose
      podman-tui
    ];

    # Tells Kind to use Podman
    environment.sessionVariables = {
      KIND_EXPERIMENTAL_PROVIDER = "podman";
    };

    systemd.services."user@".serviceConfig.Delegate = "cpu cpuset io memory pids";
  };
}
