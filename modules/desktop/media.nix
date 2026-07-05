{ pkgs, inputs, ... }:

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

    (pkgs.symlinkJoin {
      name = "qbz-wrapped";
      paths = [
        (inputs.qbz.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (oldAttrs: {
          doCheck = false;

          buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.libjack2 ];
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
            pkgs.jq
            pkgs.pkg-config
          ];

          postPatch = (oldAttrs.postPatch or "") + ''
            for file in src-tauri/tauri.conf.json tauri.conf.json; do
              if [ -f "$file" ]; then
                jq '.bundle.createUpdaterArtifacts = false' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
              fi
            done
          '';
        }))
      ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/qbz \
          --prefix LD_LIBRARY_PATH : "${
            pkgs.lib.makeLibraryPath [
              pkgs.pipewire
              pkgs.alsa-lib
              pkgs.libpulseaudio
              pkgs.libjack2
            ]
          }" \
          --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${
            pkgs.lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
              pkgs.gst_all_1.gstreamer
              pkgs.gst_all_1.gst-plugins-base
              pkgs.gst_all_1.gst-plugins-good
              pkgs.pipewire
            ]
          }"
      '';
    })
  ];
}
