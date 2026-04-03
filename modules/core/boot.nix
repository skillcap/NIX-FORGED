{ pkgs, lib, config, inputs, ... }:

{
  options = {
      modules.core.boot = {
        enable = lib.mkEnableOption "Custom boot configuration";
        nvidia.enable = lib.mkEnableOption "Nvidia specific kernel parameters";
      };
    };

  config = lib.mkIf config.modules.core.boot.enable {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      cores = 0;
      max-jobs = "auto";
      http-connections = 128;
      max-substitution-jobs = 128;
      substituters = [
        "https://cache.nixos.org?priority=10"
      ];
    };

    # --- Secure Boot ---
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    boot.loader.efi.canTouchEfiVariables = true;

    # --- reduce generation display time ---
    boot.loader.timeout = 1;

    # --- Kernel Params ---
    boot.kernelParams = [
      # --- CPU Optimization ---
      "amd_pstate=active"                    # Let the CPU manage its own frequency
      "amd_pstate.epp=performance"           # Bias the CPU toward maximum performance over power savings
      "initcall_blacklist=acpi_cpufreq_init" # Prevent conflicts with old driver
      "nowatchdog"                           # Disable the kernel watchdog
      "nmi_watchdog=0"                       # Disable Non-Maskable Interrupt watchdog
      "nosoftlockup"                         # Disable soft lockup detector to remove polling jitter
      "preempt=full"                         # Force kernel to instantly interrupt background tasks
      "threadirqs"                           # Push hardware interrupts to threads to prevent audio dropouts
      "skew_tick=1"                          # Offset timer ticks across cores to reduce lock contention
      "workqueue.power_efficient=false"      # Prevent thread migration across cores to preserve

      # --- System Latency ---
      "split_lock_detect=off"                # Prevent stutters in unoptimized software
      "transparent_hugepage=madvise"         # Faster memory pages for large assets on request
      "tsc=reliable"                         # to improve cross-system latency
      "clocksource=tsc"                      # in conjunction with above
    ] ++ lib.optionals config.modules.core.boot.nvidia.enable [
      # --- Graphics ---
      "nvidia-drm.modeset=1"                 # Required for Wayland; enables Direct Rendering Manager mode-setting
      "nvidia-drm.fbdev=1"                   # Fixes Wayland flickering and high-res TTY consoles on NVIDIA
    ];

    powerManagement.cpuFreqGovernor = "performance";

    # --- Memory Management & Compression ---
    # Dynamic RAM disk for tempfiles, remove/reduce for systems with less RAM.
    # Saves on SSD writes.
    boot.tmp = {
      useTmpfs = true;
      tmpfsSize = "67%"; # ~64GB before compression
    };

    # zstd hits a 1:3 ratio, lz4 hits 1:2 with better performance.
    # For my system:
    # zstd: 96->~192gb @ ~3-5% potential penalty
    # lz4: 96->~144gb @ ~0.5-1.5% potential penalty
    # Find what works best for your needs.
    zramSwap = {
      enable = true;
      algorithm = "lz4";
      memoryPercent = 100;
    };

    boot.kernel.sysctl = {
      "vm.swappiness" = 180;             # zram is fast
      "vm.vfs_cache_pressure" = 50;      # Hold onto metadata longer
      "vm.compaction_proactiveness" = 0; # remove for servers, reduces random cpu spikes from memory defragmentation.
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page_lock_unfairness" = 1;     # tldr, improves system latency
      # networking
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3; # Speeds up repeated connections
    };
    boot.kernelModules = [ "tcp_bbr" "ntsync" ];

    # --- CachyOS LTS compiled locally for native instruction set ---
    boot.kernelPackages = let
      # LTS to ensure compatibility with Nvidia 590.xx drivers
      # Unfortunately LTO breaks the NVIDIA open drivers at the moment
      baseKernel = inputs.nix-cachyos-kernel.packages.${pkgs.system}.linux-cachyos-lts;

      optimizedKernel = baseKernel.overrideAttrs (old: {
        modDirVersion = "${old.version}-cachyos-znver5-v4-fixed";

        # Inject Zen 5 Native AVX-512 flags
        preConfigure = (old.preConfigure or "") + ''
          export KCFLAGS="-march=native -O3 -pipe"
          export KCPPFLAGS="-march=native -O3 -pipe"
        '';

        separateDebugInfo = false;
      });
    in
      pkgs.linuxPackagesFor optimizedKernel;

    # --- AppImage Support ---
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    environment.systemPackages = with pkgs; [
      sbctl # Secure boot management
    ];

    # --- Reduce Reboot Delays ---
    systemd.user.extraConfig = ''
      DefaultTimeoutStopSec=10s
      DefaultTimeoutStartSec=10s
    '';

    # --- Filesystem optimization ---
    fileSystems."/".options = [ "discard=async" ];

    # --- DNS ---
    networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  };
}
