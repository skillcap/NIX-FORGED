{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    appimage-run
    discord-ptb
    nil
    nixd
    obsidian
    orca-slicer
    pcmanfm
    telegram-desktop
    vivaldi
    (symlinkJoin {
      name = "zed-xwayland";
      paths = [ zed-editor ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/zeditor \
        --unset WAYLAND_DISPLAY \
        --set LIBGL_ALWAYS_SOFTWARE 1 \
        --set ZED_GL_DISABLE 1

        # Delete the unwrapped 'zed' symlink and re-point it to our wrapped binary
        rm -f $out/bin/zed
        ln -s $out/bin/zeditor $out/bin/zed
      '';
    })
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
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
