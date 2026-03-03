{ pkgs, lib, config, ... }:

{
  options = {
    modules.core.system-cli = {
      enable = lib.mkEnableOption "System CLI";
    };
  };

  config = lib.mkIf config.modules.core.system-cli.enable {
    programs.fish.enable = true;
    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
      git
      wget
      vim
      ripgrep
      ripgrep-all
      bat
      slurm
      util-linux
      zip
      unzip
      tree
      age
      sops
    ];
  };
}
