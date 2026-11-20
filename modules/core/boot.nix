{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  cfg = config.modules.core.boot;
  cachyHelpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { };
in
{
  options.modules.core.boot = {
    enable = lib.mkEnableOption "Custom boot configuration";

    kernelBranch = lib.mkOption {
      type = lib.types.enum [
        "lts"
        "latest"
      ];
      default = "lts";
      description = "CachyOS kernel release stream (lts or latest).";
    };

    cpuVendor = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "amd"
          "intel"
        ]
      );
      default = null;
      description = "The CPU vendor for applying specific pstate driver optimizations.";
    };

    cpuOptimization = lib.mkOption {
      type = lib.types.enum [
        "generic"
        "zen3"
        "zen4"
        "zen5"
      ];
      default = "generic";
      description = "Specific microarchitecture for pulling optimized pre-compiled kernels.";
    };

    compileLocally = lib.mkEnableOption "Compile the kernel locally with -march=native";
    hasNvidia = lib.mkEnableOption "Nvidia proprietary Wayland tweaks";
    largeMemory = lib.mkEnableOption "Optimizations for systems with large amounts of RAM (tmpfs, zram)";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # --- Base Configuration ---
        nix = {
          package = pkgs.lix;
          settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            auto-optimise-store = true;
            # Throttle the laptop's local builds to avoid OOM; other profiles stay unlimited.
            cores = if config.host.profile == "laptop" then 4 else 0;
            max-jobs = if config.host.profile == "laptop" then 1 else "auto";
            http-connections = 128;
            max-substitution-jobs = 128;
            substituters = [
              "https://cache.nixos.org?priority=10"
              "https://cache.lantian.pub/lantian"
              "https://cache.xinux.uz"
              "https://cache.numtide.com"
            ];
            trusted-public-keys = [
              "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
              "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
              "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
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
        boot.loader.timeout = 1;

        # --- Base Kernel Params ---
        boot.kernelParams = [
          "split_lock_detect=off"
          "transparent_hugepage=madvise"
          "tsc=reliable"
          "clocksource=tsc"
        ];

        boot.kernel.sysctl = {
          "vm.vfs_cache_pressure" = 50;
          "vm.page_lock_unfairness" = 1;
          "net.core.default_qdisc" = "fq";
          "net.ipv4.tcp_congestion_control" = "bbr";
          "net.ipv4.tcp_fastopen" = 3;
        };

        boot.kernelModules = [
          "tcp_bbr"
          "ntsync"
          "sg"
        ];

        # --- Dynamic Kernel Selection ---
        boot.kernelPackages =
          if config.host.profile == "server" then
            pkgs.linuxPackages_hardened
          else
            let
              # CachyOS uses the -zen4 package target for both Zen 4 and Zen 5 CPUs
              archSuffix =
                if cfg.cpuOptimization == "generic" then
                  ""
                else if (cfg.cpuOptimization == "zen4" || cfg.cpuOptimization == "zen5") then
                  "-zen4"
                else
                  "-${cfg.cpuOptimization}";

              marchFlag =
                if cfg.cpuOptimization == "zen5" then
                  "znver5"
                else
                  "native";

              rawKernel =
                inputs.nix-cachyos-kernel.packages.${pkgs.stdenv.hostPlatform.system}."linux-cachyos-${cfg.kernelBranch}-lto${archSuffix}";

              optimizedKernel = rawKernel.overrideAttrs (old: {
                modDirVersion = "${old.version}-cachyos-custom";
                NIX_ENFORCE_NO_NATIVE = 0;
                preConfigure = (old.preConfigure or "") + ''
                  export KCFLAGS="$KCFLAGS -march=${marchFlag} -O3 -pipe"
                  export KCPPFLAGS="$KCPPFLAGS -march=${marchFlag} -O3 -pipe"
                '';
                separateDebugInfo = false;
              });
            in
            if cfg.compileLocally then
              cachyHelpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor optimizedKernel)
            else
              inputs.nix-cachyos-kernel.legacyPackages.${pkgs.stdenv.hostPlatform.system}."linuxPackages-cachyos-${cfg.kernelBranch}-lto${archSuffix}";

        # --- AppImage & Flatpak Support ---
        programs.appimage = {
          enable = true;
          binfmt = true;
        };
        services.flatpak.enable = true;
        xdg.portal.enable = true;

        environment.systemPackages = with pkgs; [
          sbctl
        ];

        # --- Reduce Reboot Delays ---
        systemd.user.settings.Manager = {
          DefaultTimeoutStopSec = "10s";
          DefaultTimeoutStartSec = "10s";
        };

        # --- Filesystem optimization ---
        fileSystems."/".options = [
          "discard=async"
        ]
        ++ lib.optionals (config.host.profile != "server") [ "noatime" ];

        # --- DNS ---
        networking.nameservers = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      }

      # --- Graphics & Out-of-Tree Driver Patching ---
      (lib.mkIf cfg.hasNvidia {
        boot.kernelParams = [
          "nvidia-drm.modeset=1"
          "nvidia-drm.fbdev=1"
        ];

        # Override the .open sub-attribute on nvidiaPackages.beta when using the 7.2+ latest branch
        hardware.nvidia.package = lib.mkIf (cfg.kernelBranch == "latest") (
          let
            baseNvidia = config.boot.kernelPackages.nvidiaPackages.beta;
          in
          lib.mkForce (
            baseNvidia
            // {
              open = baseNvidia.open.overrideAttrs (old: {
                patches = (old.patches or [ ]) ++ [
                  (pkgs.fetchpatch {
                    url = "https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/nvidia/nvidia-utils/0001-make-Add-support-for-7.2-Kernel.patch";
                    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace via nix-prefetch-url if switching to latest
                  })
                ];
              });
            }
          )
        );
      })

      # --- Large Memory Optimizations ---
      (lib.mkIf cfg.largeMemory {
        boot.tmp = {
          useTmpfs = true;
          tmpfsSize = "67%";
        };

        zramSwap = {
          enable = true;
          algorithm = "lz4";
          memoryPercent = 100;
        };

        boot.kernel.sysctl = {
          "vm.swappiness" = 180;
          "vm.watermark_boost_factor" = 0;
          "vm.watermark_scale_factor" = 125;
          "vm.dirty_bytes" = 268435456; # 256MB cap before async writeback
          "vm.dirty_background_bytes" = 67108864; # 64MB background writeback trigger
        };
      })

      # --- CPU Vendor Matching ---
      (lib.mkIf (cfg.cpuVendor == "amd") {
        boot.kernelParams = [
          "amd_pstate=active"
          "initcall_blacklist=acpi_cpufreq_init"
        ];

        boot.kernelModules = lib.optionals (cfg.cpuOptimization == "zen4" || cfg.cpuOptimization == "zen5") [
          "amd_3d_vcache"
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
          "nowatchdog"
          "nmi_watchdog=0"
          "nosoftlockup"
          "preempt=full"
          "threadirqs"
          "skew_tick=1"
          "workqueue.power_efficient=false"
        ]
        ++ lib.optionals (cfg.cpuVendor == "amd") [
          "amd_pstate.epp=performance"
        ];

        boot.kernel.sysctl = {
          "vm.compaction_proactiveness" = 0;
        };

        # Use powersave governor when amd_pstate=active is enabled so EPP controls per-core boost
        powerManagement.cpuFreqGovernor =
          if cfg.cpuVendor == "amd" then "powersave" else "performance";
      })

      (lib.mkIf (config.host.profile == "laptop") {
        boot.kernelParams = [
          "workqueue.power_efficient=true"
        ]
        ++ lib.optionals (cfg.cpuVendor == "amd") [
          "amd_pstate.epp=power"
        ];

        powerManagement.cpuFreqGovernor = "powersave";

        # mkDefault so the largeMemory block can still win on a laptop if ever enabled.
        zramSwap = {
          enable = lib.mkDefault true;
          algorithm = lib.mkDefault "lz4";
          memoryPercent = lib.mkDefault 100;
        };
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
    ]
  );
}
