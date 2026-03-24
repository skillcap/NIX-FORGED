{ pkgs, lib, config, ... }:

{
  options = {
    modules.hardware.audio = {
      enable = lib.mkEnableOption "Low latency HD Audio configuration.";
    };
  };

  config = lib.mkIf config.modules.hardware.audio.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      # Low-Latency, HD audio
      extraConfig.pipewire."99-quality" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 352800 384000 ];
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 2048;
          "stream.properties" = {
            "resample.quality" = 10;
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      pavucontrol
    ];
  };
}
