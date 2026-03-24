{ config, pkgs, lib, ... }:

{
  # --- Cursor Theme ---
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  # --- GTK Theme ---
  gtk = {
    gtk4.theme = null;
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";
  };

  home.packages = with pkgs; [
    wl-clipboard
    libnotify
    cava
  ];

  programs.kitty = {
    enable = true;

    font = {
      name = "CaskaydiaCove Nerd Font";
      package = pkgs.nerd-fonts.caskaydia-cove;
      size = 12.0;
    };

    settings = {
      window_padding_width = 12;
      background_opacity = "0.8";
      hide_window_decorations = "yes";
      dynamic_background_opacity = "yes";

      cursor_shape = "block";
      cursor_blink_interval = 1;

      scrollback_lines = 3000;

      copy_on_select = "yes";
      strip_trailing_spaces = "smart";

      tab_bar_style = "powerline";
      tab_bar_align = "left";

      shell_integration = "enabled";

      # feels nice, but remove to save power on laptops
      input_delay = 1;
      repaint_delay = 5;
      sync_to_monitor = "yes";

      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
    };

    keybindings = {
      "ctrl+shift+n" = "new_window";
      "ctrl+t" = "new_tab";
      "ctrl+plus" = "change_font_size all +1.0";
      "ctrl+minus" = "change_font_size all -1.0";
      "ctrl+0" = "change_font_size all 1";
    };

    extraConfig = ''
      include dank-tabs.conf
      include dank-theme.conf
    '';
  };

  # Symlinks
  xdg.configFile = {
    "hypr".source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/hypr");
  };
}
