{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    btop
    eza
    fd
    hwloc
    jq
    yq
    neovim
    nitch
    sd
    starship
    wiki-tui
  ];

  imports = [
    ./fastfetch.nix
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fish_vi_key_bindings
    '';
    shellAbbrs = {
      nrs = "sudo git -C /etc/nixos add . && sudo git -C /etc/nixos status -s && sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
      nrt = "sudo git -C /etc/nixos add . && sudo git -C /etc/nixos status -s && sudo nixos-rebuild test --flake /etc/nixos#$(hostname)";
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
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
    ];
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "tokyonight_transparent";
      keys.normal = {
        "C-h" = [
          ":sh rm -f /tmp/hx-yazi"
          ":insert-output yazi --chooser-file=/tmp/hx-yazi"
          ":open %sh{cat /tmp/hx-yazi}"
          ":redraw"
        ];
        "{" = "goto_prev_paragraph";
        "}" = "goto_next_paragraph";
      };
      keys.select = {
        "{" = "goto_prev_paragraph";
        "}" = "goto_next_paragraph";
      };
    };
    languages.language = [{
        name = "nix";
        auto-format = false;
        formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
      }];
    themes = {
      tokyonight_transparent = {
        "inherits" = "tokyonight";
        "ui.background" = { };
      };
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "tokyo-night";
    };
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
      vim_keys = true;
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
        edit = [ { run = "hx \"$@\""; block = true; } ];
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
    EDITOR = "hx";
  };

  xdg.configFile = {
    "starship.toml".source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/starship.toml");
  };
}
