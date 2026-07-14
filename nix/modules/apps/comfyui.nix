{config, lib, pkgs, inputs, ...}: let
  cfg = config.my.comfyui;
  ai = config.my.mounts.ai;

  # nix-comfyui pins tbb_2021_11; nixpkgs 25.11 renamed it to tbb_2021.
  pkgsComfyui = import inputs.nixpkgs {
    inherit (pkgs) system;
    config = pkgs.config;
    overlays = [
      (final: prev: {
        tbb_2021_11 = prev.tbb_2021;
      })
      inputs.nix-comfyui.overlays.default
    ];
  };

  # Upstream only publishes cuda and rocm Poetry envs (no Intel/XPU build).
  comfyuiPackage = pkgsComfyui.comfyuiPackages.${cfg.packageVariant}.comfyui;

  effectiveListenAddress =
    if cfg.expose == "localhost"
    then "127.0.0.1"
    else "0.0.0.0";

  comfyuiArgs = lib.concatStringsSep " " [
    "--listen"
    effectiveListenAddress
    "--port"
    (toString cfg.port)
    (lib.optionalString cfg.cpuOnly "--cpu")
  ];

  stateDirectoryName = builtins.baseNameOf (builtins.toString cfg.dataDir);
in {
  options.my.comfyui = {
    enable = lib.mkEnableOption "ComfyUI server";

    cpuOnly = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Run inference on CPU only. Use on hosts without an NVIDIA or AMD GPU
        (e.g. Framework 12 with Intel graphics). nix-comfyui has no Intel IPEX
        or OpenVINO packaging; this passes ComfyUI's --cpu flag.
      '';
    };

    packageVariant = lib.mkOption {
      type = lib.types.enum ["cuda" "rocm"];
      default = "cuda";
      description = ''
        nix-comfyui Python stack to install. Does not match the host GPU vendor;
        pick cuda unless you are on AMD and using ROCm without cpuOnly.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8188;
      description = "TCP port for the ComfyUI web UI.";
    };

    expose = lib.mkOption {
      type = lib.types.enum ["localhost" "tailscale" "lan"];
      default = "tailscale";
      description = ''
        localhost: bind listenAddress (default 127.0.0.1); no firewall changes.
        tailscale: bind 0.0.0.0; rely on trustedInterfaces for Tailscale only
        (do not open the port on wlan/eth).
        lan: bind 0.0.0.0 and allow the port through the firewall on all interfaces.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/comfyui";
      description = ''
        Per-app state: custom_nodes, output, user settings.
        Use /mnt/local/appdata/comfyui on storage hosts (galar) with ZFS;
        use /var/lib/comfyui on workstations when local appdata ownership is unreliable.
        Large models belong on /mnt/ai (see my.comfyui.sharedModels).
      '';
    };

    sharedModels = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Symlink dataDir/models to /mnt/ai/models/image when my.mounts.ai is enabled.
      '';
    };

    useStateDirectory = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Create dataDir via systemd StateDirectory with correct service ownership.
        Disable when using a custom path under /mnt/local on storage hosts.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.sharedModels || ai.enable;
          message = "my.comfyui.sharedModels requires my.mounts.ai.enable";
        }
      ];
    }
    {
      users.users.comfyui = {
        isSystemUser = true;
        uid = 985;
        group = "comfyui";
        extraGroups = ["video" "render"] ++ lib.optionals ai.enable ["ai"];
        home = cfg.dataDir;
        createHome = lib.mkIf (!cfg.useStateDirectory) true;
        description = "ComfyUI daemon user";
      };
      users.groups.comfyui = {};

      systemd.tmpfiles.rules = lib.mkIf (!cfg.useStateDirectory) [
        "d /mnt/local/appdata 0755 root root -"
        "z ${cfg.dataDir}              0770 comfyui comfyui -"
        "z ${cfg.dataDir}/custom_nodes 0770 comfyui comfyui -"
        "Z ${cfg.dataDir}              -    comfyui comfyui -"
      ];

      systemd.services.comfyui = {
        enable = true;
        description = "ComfyUI Server";
        wantedBy = ["multi-user.target"];
        after = [
          "network.target"
          "local-fs.target"
        ]
        ++ lib.optionals (cfg.sharedModels && ai.enable) ["mnt-ai.mount"];

        # bwrap mounts a tmpfs over $PWD; only state_dirs survive. custom_nodes must
        # be declared or ComfyUI cannot see the directory (see nix-comfyui wrapper.py).
        environment.NIX_COMFYUI_STATE_DIRS = "custom_nodes";

        serviceConfig =
          {
            ExecStartPre = ''
              ${pkgs.coreutils}/bin/install -d -o comfyui -g comfyui -m 0770 ${cfg.dataDir}
              ${pkgs.coreutils}/bin/install -d -o comfyui -g comfyui -m 0770 ${cfg.dataDir}/custom_nodes
              ${
                lib.optionalString (cfg.sharedModels && ai.enable) ''
                  if [ ! -L ${cfg.dataDir}/models ] || [ "$(readlink ${cfg.dataDir}/models)" != "${ai.mountPoint}/models/image" ]; then
                    ${pkgs.coreutils}/bin/ln -sfn ${ai.mountPoint}/models/image ${cfg.dataDir}/models
                  fi
                ''
              }
            '';
            ExecStart = "${comfyuiPackage}/bin/comfyui ${comfyuiArgs}";
            User = "comfyui";
            Group = "comfyui";
            WorkingDirectory = cfg.dataDir;
            Restart = "on-failure";
            RestartSec = "5s";
          }
          // lib.optionalAttrs cfg.useStateDirectory {
            StateDirectory = stateDirectoryName;
            StateDirectoryMode = "0770";
          };
      };

      environment.systemPackages = [comfyuiPackage];
    }
    (lib.mkIf (cfg.expose == "lan") {
      networking.firewall.allowedTCPPorts = [cfg.port];
    })
  ]);
}
