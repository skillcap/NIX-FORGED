{ pkgs, ... }:

let
  nixos-logo-png =
    pkgs.runCommand "nixos-logo.png"
      {
        buildInputs = [ pkgs.imagemagick ];
      }
      ''
        magick -density 1200 -background none ${
          pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake-colours.svg";
            hash = "sha256-43taHBHoFJbp1GrwSQiVGtprq6pBbWcKquSTTM6RLrI=";
          }
        } -resize 1000x1000 $out
      '';
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "${nixos-logo-png}";
        type = "kitty-direct";
        width = 50;
        height = 25;
        padding = {
          top = 1;
          right = 2;
        };
      };
      modules = [
        "break"
        {
          type = "custom";
          format = "${builtins.fromJSON "\"\\u001b\""}[90m┌──────────────────────Hardware──────────────────────┐";
        }
        {
          type = "command";
          key = " PC";
          keyColor = "green";
          text = "hostname";
        }
        {
          type = "cpu";
          key = "│ ├";
          keyColor = "green";
        }
        {
          type = "gpu";
          key = "│ ├󰍛";
          keyColor = "green";
        }
        {
          type = "memory";
          key = "│ ├󰍛";
          keyColor = "green";
        }
        {
          type = "disk";
          key = "└ └";
          keyColor = "green";
        }
        {
          type = "custom";
          format = "${builtins.fromJSON "\"\\u001b\""}[90m└────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "${builtins.fromJSON "\"\\u001b\""}[90m┌──────────────────────Software──────────────────────┐";
        }
        {
          type = "os";
          key = " OS";
          keyColor = "yellow";
        }
        {
          type = "kernel";
          key = "│ ├";
          keyColor = "yellow";
        }
        {
          type = "bios";
          key = "│ ├";
          keyColor = "yellow";
        }
        {
          type = "packages";
          key = "│ ├󰏖";
          keyColor = "yellow";
        }
        {
          type = "shell";
          key = "└ └";
          keyColor = "yellow";
        }
        "break"
        {
          type = "de";
          key = " DE";
          keyColor = "blue";
        }
        {
          type = "lm";
          key = "│ ├";
          keyColor = "blue";
        }
        {
          type = "wm";
          key = "│ ├";
          keyColor = "blue";
        }
        {
          type = "wmtheme";
          key = "│ ├󰉼";
          keyColor = "blue";
        }
        {
          type = "terminal";
          key = "└ └";
          keyColor = "blue";
        }
        {
          type = "custom";
          format = "${builtins.fromJSON "\"\\u001b\""}[90m└────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "${builtins.fromJSON "\"\\u001b\""}[90m┌──────────────────Uptime / Age / DT─────────────────┐";
        }
        {
          type = "command";
          key = "  OS Age ";
          keyColor = "magenta";
          text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
        }
        {
          type = "uptime";
          key = "  Uptime ";
          keyColor = "magenta";
        }
        {
          type = "datetime";
          key = "  DateTime ";
          keyColor = "magenta";
        }
        {
          type = "custom";
          format = "${builtins.fromJSON "\"\\u001b\""}[90m└────────────────────────────────────────────────────┘";
        }
        {
          type = "colors";
          paddingLeft = 2;
          symbol = "circle";
        }
      ];
    };
  };

  programs.fish.shellAbbrs.ff = "fastfetch";
}
