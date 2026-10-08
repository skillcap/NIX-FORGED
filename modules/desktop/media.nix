{ pkgs, ... }:

let
  shaders_dir = "${pkgs.mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders";
in
{
  programs.obs-studio = {
    enable = true;
    # optional Nvidia hardware acceleration
    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi
      obs-gstreamer
      obs-vkcapture
    ];
  };

  programs.mpv = {
    enable = true;

    scripts = with pkgs.mpvScripts; [
      uosc # Modern UI
      mpris # Media keys
      sponsorblock # Skip sponsors
    ];

    config = {
      vo = "gpu-next";
      gpu-api = "vulkan";
      hwdec = "nvdec-copy";
      video-sync = "display-resample";
      interpolation = "yes";
      tscale = "oversample";

      profile = "high-quality";
      scale = "ewa_lanczossharp";
      cscale = "spline36";

      # HDR to SDR Tonemapping
      tone-mapping = "bt.2446a";
      hdr-compute-peak = "yes";

      glsl-shader = "~~/shaders/FSRCNNX_x2_8-0-4-1.glsl";
    };
  };

  home.file.".config/mpv/shaders/FSRCNNX_x2_8-0-4-1.glsl".source =
    "${shaders_dir}/FSRCNNX_x2_8-0-4-1.glsl";

  home.packages = with pkgs; [
    playerctl

  ];
}
