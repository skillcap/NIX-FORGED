{ ... }:

{
  imports = [
    ./core/cli.nix
    ./desktop/apps.nix
    ./desktop/games.nix
    ./desktop/hyprland-user.nix
    ./desktop/media.nix
    ./development/kubernetes.nix
    ./development/tools.nix
    ./security/secrets.nix
    ./services/ai.nix
    ./services/rclone.nix
  ];
}
