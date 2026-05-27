{ pkgs, config, inputs, ... }:

{
  home.packages = [
    inputs.nix-gaming.packages.${pkgs.system}.osu-lazer-bin
    (pkgs.prismlauncher.override {
      additionalLibs = with pkgs; [
        vulkan-loader
        libglvnd
        linuxPackages.nvidia_x11
        stdenv.cc.cc.lib
        libX11       # Required for Vulkan surface creation
        wayland           # Required for Hyprland
        libxkbcommon
      ];
    })
  ];

  xdg.dataFile."flatpak/overrides/com.hypixel.HytaleLauncher" = {
    text = ''
      [Context]
      shared=ipc;
      sockets=wayland;
      devices=all;
      filesystems=xdg-run/gamemode;

      [Environment]
      MANGOHUD=1
      MANGOHUD_CONFIG=position=top-left,toggle_hud=bracketright,fps,frametime,cpu_temp,gpu_temp,vram,ram,core_bars,no_display,fps_limit=173,fps_limit_method=late
    '';
  };

  xdg.desktopEntries = {
    "osu-lazer-pinned" = {
      name = "osu! (Pinned)";
      exec = "gs osu!";
      icon = "osu!";
      terminal = false;
      type = "Application";
      categories = [ "Game" ];
      comment = "osu! pinned to 3D V-Cache CCD with gs environment";
    };

    "hytale-pinned" = {
      name = "Hytale (Pinned)";
      exec = "gs-flatpak flatpak run com.hypixel.HytaleLauncher";
      icon = "hytale"; # Update with actual icon name if needed
      terminal = false;
      type = "Application";
      categories = [ "Game" ];
      comment = "Hytale pinned to 3D V-Cache CCD with gs environment";
    };
  };
}
