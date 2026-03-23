{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    (lib.hiPrio clang)
    cargo
    cargo-info
    clippy
    rustfmt
    rust-analyzer
    bacon
    mold
    rustc
    rusty-man
    elixir
    beam.packages.erlang.erlang
    nodejs
    python315
    uv
    tokei
    (lib.lowPrio gcc)
    gnumake
    gitui
    delta
    jujutsu
  ];

  xdg.desktopEntries.livebook = {
      name = "Livebook";
      genericName = "Elixir runner";
      exec = "appimage-run /home/skill/Applications/Livebook-linux-amd64.AppImage";
      terminal = false;
    };
}
