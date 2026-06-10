{ ... }:

{
  imports = [
    ./modules/default-user.nix
  ];

  home.username = "skill";
  home.homeDirectory = "/home/skill";
  home.stateVersion = "25.05";

  xdg.enable = true;
}
