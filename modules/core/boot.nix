{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.modules.core.boot;
in
{
  options.modules.core.boot = {
    enable = lib.mkEnableOption "Custom boot configuration";

    cpuVendor = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "amd" "intel" ]);
      default = null;
      description = "The CPU vendor for applying specific pstate driver optimizations.";
    };

    cpuOptimization = lib.mkOption {
      type = lib.types.enum [ "generic" "zen3" "zen4" ];
      default = "generic";
      description = "Specific microarchitecture for pulling optimized pre-compiled kernels.";
    };

    compileLocally = lib.mkEnableOption "Compile the kernel locally with -march=native";
    hasNvidia = lib.mkEnableOption "Nvidia proprietary Wayland tweaks";
    largeMemory = lib.mkEnableOption "Optimizations for systems with large amounts of RAM (tmpfs, zram)";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # --- Base Configuration ---
      nix = {
        package = pkgs.lix;
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          auto-optimise-store = true;
          cores = 0;
          max-jobs = "auto";
          http-connections = 128;
          max-substitution-jobs = 128;
          substituters = [
            "https://cache.nixos.org?priority=10"
            "https://attic.xuyh0120.win/lantian" # Precompiled CachyOS Kernel Cache
          ];
          trusted-public-keys = [
            "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          ];
        };
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

      # --- Base Kernel Params ---
      boot.kernelParams = [
        # --- System Latency ---
        "split_lock_detect=off"        # Prevent stutters in unoptimized software
        "transparent_hugepage=madvise" # Faster memory pages for large assets on request
        "tsc=reliable"                 # to improve cross-system latency
        "clocksource=tsc"              # in conjunction with above
      ];

      boot.kernel.sysctl = {
        "vm.vfs_cache_pressure" = 50;      # Hold onto metadata longer
        "vm.page_lock_unfairness" = 1;     # tldr, improves system latency
        # networking
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.ipv4.tcp_fastopen" = 3;       # Speeds up repeated connections
      };
      boot.kernelModules = [ "tcp_bbr" "ntsync" ];

      # --- Dynamic Kernel Selection ---
      boot.kernelPackages =
        if config.host.profile == "server" then
          pkgs.linuxPackages_hardened
        else if cfg.compileLocally then
          let
            baseKernel = inputs.nix-cachyos-kernel.packages.${pkgs.system}.linux-cachyos-lts;
            optimizedKernel = baseKernel.overrideAttrs (old: {
              modDirVersion = "${old.version}-cachyos-custom";
              preConfigure = (old.preConfigure or "") + ''
                export KCFLAGS="-march=native -O3 -pipe"
                export KCPPFLAGS="-march=native -O3 -pipe"
              '';
              separateDebugInfo = false;
            });
          in
            pkgs.linuxPackagesFor optimizedKernel
        else if cfg.cpuOptimization == "zen4" then
          pkgs.linuxPackagesFor inputs.nix-cachyos-kernel.packages.${pkgs.system}.linux-cachyos-lts-zen4
        else if cfg.cpuOptimization == "zen3" then
          pkgs.linuxPackagesFor inputs.nix-cachyos-kernel.packages.${pkgs.system}.linux-cachyos-lts-zen3
        else
          pkgs.linuxPackagesFor inputs.nix-cachyos-kernel.packages.${pkgs.system}.linux-cachyos-lts;

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
    }

    # --- Large Memory Optimizations ---
    (lib.mkIf cfg.largeMemory {
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
        "vm.watermark_boost_factor" = 0;
        "vm.watermark_scale_factor" = 125;
      };
    })

    # --- Graphics ---
    (lib.mkIf cfg.hasNvidia {
      boot.kernelParams = [
        # --- Graphics ---
        "nvidia-drm.modeset=1" # Required for Wayland; enables Direct Rendering Manager mode-setting
        "nvidia-drm.fbdev=1"   # Fixes Wayland flickering and high-res TTY consoles on NVIDIA
      ];
    })

    # --- CPU Vendor Matching ---
    (lib.mkIf (cfg.cpuVendor == "amd") {
      boot.kernelParams = [
        # --- CPU Optimization ---
        "amd_pstate=active"                    # Let the CPU manage its own frequency
        "initcall_blacklist=acpi_cpufreq_init" # Prevent conflicts with old driver
      ];
    })

    (lib.mkIf (cfg.cpuVendor == "intel") {
      boot.kernelParams = [
        "intel_pstate=active"
      ];
    })

    # --- Profile Matching ---
    (lib.mkIf (config.host.profile == "desktop") {
      boot.kernelParams = [
        "nowatchdog"                           # Disable the kernel watchdog
        "nmi_watchdog=0"                       # Disable Non-Maskable Interrupt watchdog
        "nosoftlockup"                         # Disable soft lockup detector to remove polling jitter
        "preempt=full"                         # Force kernel to instantly interrupt background tasks
        "threadirqs"                           # Push hardware interrupts to threads to prevent audio dropouts
        "skew_tick=1"                          # Offset timer ticks across cores to reduce lock contention
        "workqueue.power_efficient=false"      # Prevent thread migration across cores to preserve
      ] ++ lib.optionals (cfg.cpuVendor == "amd") [
        "amd_pstate.epp=performance"           # Bias the CPU toward maximum performance over power savings
      ];

      boot.kernel.sysctl = {
        "vm.compaction_proactiveness" = 0;     # Reduces random cpu spikes from memory defragmentation
      };

      powerManagement.cpuFreqGovernor = "performance";
    })

    (lib.mkIf (config.host.profile == "laptop") {
      boot.kernelParams = [
        "workqueue.power_efficient=true"
      ] ++ lib.optionals (cfg.cpuVendor == "amd") [
        "amd_pstate.epp=power"
      ];

      powerManagement.cpuFreqGovernor = "powersave";
    })

    (lib.mkIf (config.host.profile == "server") {
      boot.kernelParams = [
        "preempt=voluntary"
        "panic=60"
      ];
      boot.kernel.sysctl = {
        "kernel.panic" = 60;
        "kernel.panic_on_oops" = 1;
        "kernel.nmi_watchdog" = 1;
      };
      systemd.watchdog = {
        runtimeTime = "1m";
        rebootTime = "5m";
      };
      powerManagement.cpuFreqGovernor = "performance";
    })
  ]);
}
