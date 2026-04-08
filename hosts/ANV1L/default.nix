{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./display.nix
    ../../modules/default-system.nix
  ];

  host.profile = "desktop";
  modules.core.boot.cpuOptimization = "zen4";
  modules.core.boot.compileLocally = true;
  modules.hardware.RTX-5090-OC.enable = true;
  nixpkgs.config.allowUnfree = true;

  # --- Networking & Time ---
  networking.hostName = "ANV1L";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Chicago";
  system.stateVersion = "25.05";

  # --- User & Permissions ---
  users.users.skill = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };

  hardware.wooting.enable = true;
}
