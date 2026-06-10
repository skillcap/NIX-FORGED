{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ./display.nix
    ../../modules/default-system.nix
  ];

  host.profile = "laptop";
  modules.core.boot.cpuVendor = "intel";
  modules.core.boot.cpuOptimization = "generic";
  modules.core.boot.compileLocally = false;
  nixpkgs.config.allowUnfree = true;

  # --- Networking & Time ---
  networking.hostName = "N0M4D";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Chicago";
  system.stateVersion = "25.05";

  # --- User & Permissions ---
  users.users.skill = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    shell = pkgs.fish;
  };
  nix.settings.allowed-users = [
    "skill"
    "@wheel"
  ];
}
