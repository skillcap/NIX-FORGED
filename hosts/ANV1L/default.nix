{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./display.nix
    ../../modules/default-system.nix
  ];

  host.profile = "desktop";
  modules.core.boot.cpuOptimization = "zen5";
  modules.core.boot.compileLocally = true;
  modules.hardware.RTX-5090-OC.enable = true;
  nixpkgs.config = {
    allowUnfree = true;
  };

  # AI tooling: opencode (pre-built) + local CUDA Ollama inference on the GPU box.
  modules.services.ai = {
    enable = true;
    localLlm = {
      enable = true;
      acceleration = "cuda";
    };
  };

  # --- Networking & Time ---
  networking.hostName = "ANV1L";
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

  hardware.wooting.enable = true;
  hardware.steam-hardware.enable = true;
  hardware.uinput.enable = true;
  programs.steam.extest.enable = true;
}
