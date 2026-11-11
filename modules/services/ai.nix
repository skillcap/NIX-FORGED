{ pkgs, ... }:

{
  home.packages = [ pkgs.opencode pkgs.pi-coding-agent ];
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;

    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "2m";
    };
  };
}
