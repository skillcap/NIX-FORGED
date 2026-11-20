{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  cfg = config.modules.services.ai;
in
{
  options.modules.services.ai = {
    enable = lib.mkEnableOption "AI coding agents and tooling (opencode, pi-coding-agent)";

    localLlm = {
      enable = lib.mkEnableOption "Local Ollama inference daemon";

      acceleration = lib.mkOption {
        type = lib.types.enum [
          "cpu"
          "cuda"
          "rocm"
          "vulkan"
        ];
        default = "cpu";
        description = "Ollama compute backend. Only 'cpu' is cached on cache.nixos.org.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      # Pre-built binary (llm-agents), so opencode never compiles locally.
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
      pkgs.pi-coding-agent
    ];

    # Only opt-in hosts (e.g. ANV1L) run a local Ollama daemon.
    services.ollama = lib.mkIf cfg.localLlm.enable {
      enable = true;
      package =
        if cfg.localLlm.acceleration == "cuda" then
          pkgs.ollama-cuda
        else if cfg.localLlm.acceleration == "rocm" then
          pkgs.ollama-rocm
        else if cfg.localLlm.acceleration == "vulkan" then
          pkgs.ollama-vulkan
        else
          pkgs.ollama;

      environmentVariables = {
        OLLAMA_KEEP_ALIVE = "2m";
      };
    };
  };
}
