{ pkgs, inputs, lib, config, ... }:

let
  nvidia-oc = pkgs.rustPlatform.buildRustPackage {
    pname = "nvidia_oc";
    version = "0.1.24";
    src = inputs.nvidia-oc-src;
    cargoHash = "sha256-e6cX9P5dHDOLS06Bx1VuMpH/ilcpyFnHpttG7DDwz8U=";
  };
in
  {
    options = {
      modules.hardware.RTX-5090-OC.enable = lib.mkEnableOption "Nvidia Overclocking Service (5090)";
    };

    config = lib.mkIf config.modules.hardware.RTX-5090-OC.enable {
      systemd.services.nvidia-oc = {
        description = "Nvidia Overclocking Service";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        environment = {
          LD_LIBRARY_PATH = "/run/opengl-driver/lib";
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${nvidia-oc}/bin/nvidia_oc set --index 0 --freq-offset 250 --mem-offset 6000";
          User = "root";
          Restart = "on-failure";
        };
      };
    };
  }
