{ pkgs, ... }:

{
  home.packages = [ pkgs.rclone ];

  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "rclone mount for Google Drive";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive: %h/GoogleDrive --vfs-cache-mode full --vfs-cache-max-size 10G --vfs-cache-max-age 24h";
      ExecStop = "/run/wrappers/bin/fusermount -uz %h/GoogleDrive";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
