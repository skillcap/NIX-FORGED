{ config, pkgs, lib, inputs, ... }:

{
  home.packages = with pkgs; [
    appimage-run
    discord-ptb
    obsidian
    pcmanfm
    vivaldi
    (symlinkJoin {
      name = "zed-xwayland";
      paths = [ zed-editor ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/zeditor \
          --unset WAYLAND_DISPLAY
      '';
    })
    inputs.zen-browser.packages."${pkgs.system}".default
  ];
  programs.zathura = {
    enable = true;
    options = {
      recolor = true;
      recolor-keephue = true;
      recolor-darkcolor = "#ebdbb2";
      recolor-lightcolor = "#282828";
      default-bg = "#282828";
      default-fg = "#ebdbb2";
    };
  };
}
