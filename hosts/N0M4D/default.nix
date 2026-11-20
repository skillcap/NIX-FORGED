{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ./display.nix
    ../../modules/default-system.nix
  ];

  host.profile = "laptop";
  modules.core.boot = {
    enable = true;
    cpuVendor = "intel";
    cpuOptimization = "generic";
    kernelBranch = "lts";
    compileLocally = false;
    largeMemory = false;
  };
  nixpkgs.config.allowUnfree = true;

  # opencode (pre-built) stays available; local Ollama is disabled so nothing LLM-related builds.
  modules.services.ai = {
    enable = true;
    localLlm = {
      enable = false;    # set to true, acceleration "cpu", for cached CPU Ollama
      acceleration = "cpu";
    };
  };

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
