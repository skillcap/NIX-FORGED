{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    btop
    eza
    fastfetch
    fd
    hwloc
    jq
    neovim
    nitch
    sd
    starship
    wiki-tui
    zellij
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fish_vi_key_bindings
    '';
    shellAbbrs = {
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
      nrt = "sudo nixos-rebuild test --flake /etc/nixos#$(hostname)";
      nv = "nvim";
      cat = "bat";
      ls = "eza";
      l = "eza -la";
      cd = "z";
    };
    plugins = [
      {
        name = "bang-bang";
        src = pkgs.fishPlugins.bang-bang.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
        # requires fzf, fd, bat
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
    ];
  };
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
      theme_background = false;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    settings = {
      opener = {
        edit = [ { run = "nvim \"$@\""; block = true; } ];
      };
      preview = {
        image_delay = 0;
        image_filter = "lanczos3";
        max_width = 1500;
        max_height = 1500;
      };
    };
  };

  programs.nushell.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  xdg.configFile = {
    "starship.toml".source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/starship.toml");
  };
}
