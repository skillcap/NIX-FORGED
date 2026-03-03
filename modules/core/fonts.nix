{ pkgs, lib, config, ... }:

{
  options = {
      modules.core.fonts = {
        enable = lib.mkEnableOption "Nerdfonts";
      };
    };

  config = lib.mkIf config.modules.core.fonts.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-cove
    ];
  };
}
