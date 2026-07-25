{ config, lib, pkgs, ... }:

let
  cfg = config.my.mounts;
  net = import ../../lib/network.nix;
  servers = {
    nas = net.hosts.well-of-mimir-2.magicDns;
    legacy_nas = net.hosts.legacy_nas.magicDns;
    media_server = net.hosts.galar.magicDns;
  };

  aiMountPoint = "/mnt/ai";

  # Fixed across galar (NFS server) and sleipnir (NFS client) so group-writable
  # paths under /mnt/ai behave consistently over NFS.
  aiGid = 984;

  anyNfsEnabled =
    (cfg.media.enable && cfg.media.mode == "remote")
    || (cfg.vault.enable && cfg.vault.mode == "remote")
    || (cfg.backup.enable && cfg.backup.mode == "remote")
    || (cfg.ai.enable && cfg.ai.mode == "remote")
    || (cfg.hermes.enable && cfg.hermes.mode == "remote")
    || cfg.legacyPaths.enable;

  # mountPoint: stable path apps use (e.g. /mnt/ai). localPath: backing store on disk.
  mkMountOpt = name: defaultLocalPath: mountPoint: {
    enable = lib.mkEnableOption "${name} Mount";
    writable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to mount read-write (remote mode only; server must also export rw).";
    };
    mode = lib.mkOption {
      type = lib.types.enum ["remote" "local"];
      default = "remote";
      description = "Whether to mount via NFS (remote) or Bind Mount (local)";
    };
    localPath = lib.mkOption {
      type = lib.types.path;
      default = defaultLocalPath;
      description = "Backing directory on the storage host (local mode) or NFS mount target (physicalSource).";
    };
    mountPoint = lib.mkOption {
      type = lib.types.path;
      default = mountPoint;
      description = "Stable path exposed to applications; keep fixed when moving backing storage.";
    };
  };

  aiImageSubdirs = [
    "checkpoints"
    "loras"
    "vae"
    "clip"
    "controlnet"
  ];

  aiTmpfiles =
    map (sub: "d ${cfg.ai.localPath}/models/image/${sub} 2770 root ai -") aiImageSubdirs
    ++ [
      "d ${cfg.ai.localPath}              2770 root ai -"
      "d ${cfg.ai.localPath}/models       2770 root ai -"
      "d ${cfg.ai.localPath}/models/llm   2770 root ai -"
      "d ${cfg.ai.localPath}/models/image 2770 root ai -"
      "d ${cfg.ai.localPath}/workflows    2770 root ai -"
      "d ${cfg.ai.localPath}/workflows/comfyui 2770 root ai -"
    ];
in {
  options.my.mounts = {
    media = mkMountOpt "Media" "/mnt/local/media" "/mnt/media";
    vault = mkMountOpt "Vault" "/mnt/local/vault" "/mnt/vault";
    backup = mkMountOpt "Backup" "/mnt/local/backup" "/mnt/backup";

    ai = mkMountOpt "AI" "/mnt/local/ai" aiMountPoint // {
      exportNfs = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Export mountPoint on the Tailscale network (enable on galar).";
      };
      remoteSource = lib.mkOption {
        type = lib.types.str;
        default = "${servers.nas}:${aiMountPoint}";
        description = ''
          NFS source for remote clients (sleipnir, galar).
        '';
      };
      nfsClientIps = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["100.109.178.115"];
        description = ''
          Tailscale IPs allowed to mount mountPoint when exportNfs is true.
          Use per-node Tailscale IPs (not MagicDNS hostnames): nfs-server resolves
          export entries at boot before Tailscale DNS is ready.
        '';
      };
    };

    hermes = mkMountOpt "Hermes" "/mnt/local/appdata/hermes" "/mnt/hermes" // {
      exportNfs = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Export mountPoint on the Tailscale network.";
      };
      remoteSource = lib.mkOption {
        type = lib.types.str;
        default = "${servers.nas}:/mnt/hermes";
        description = "NFS source for remote clients.";
      };
      nfsClientIps = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Tailscale IPs allowed to mount mountPoint when exportNfs is true.";
      };
    };

    legacyPaths = {
      enable = lib.mkEnableOption "Legacy Mount Paths (/mnt/well-of-mimir/...)";
    };
  };

  config = lib.mkMerge [
    # ============================================================================
    # NFS SUPPORT (auto-enabled when any remote mount is active)
    # ============================================================================
    (lib.mkIf anyNfsEnabled {
      boot.supportedFilesystems = ["nfs"];
      environment.systemPackages = [pkgs.nfs-utils];
    })

    # ============================================================================
    # AI — shared models & workflows at /mnt/ai
    # ============================================================================
    (lib.mkIf cfg.ai.enable {
      users.groups.ai.gid = aiGid;
    })

    (lib.mkIf (cfg.ai.enable && cfg.ai.exportNfs) {
      assertions = [
        {
          assertion = cfg.ai.nfsClientIps != [];
          message = "my.mounts.ai.exportNfs requires at least one entry in my.mounts.ai.nfsClientIps";
        }
      ];
    })

    (lib.mkIf (cfg.ai.enable && cfg.ai.mode == "local") {
      systemd.tmpfiles.rules = aiTmpfiles;

      # tmpfiles-resetup runs during nixos-rebuild before ZFS datasets mount; re-apply
      # after localPath is available so a newly created dataset gets its layout.
      systemd.services.ai-store-init = {
        description = "Create AI store directories after backing filesystem is mounted";
        wantedBy = ["multi-user.target"];
        after = ["mnt-local-ai.mount"];
        requires = ["mnt-local-ai.mount"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${pkgs.systemd}/bin/systemd-tmpfiles --create --prefix=${cfg.ai.localPath}
        '';
      };

      systemd.mounts = [
        {
          type = "none";
          what = cfg.ai.localPath;
          where = cfg.ai.mountPoint;
          mountConfig.Options = "bind";
          after = ["zfs-mount.service"];
          requires = ["zfs-mount.service"];
          wantedBy = ["multi-user.target"];
        }
      ];
    })

    (lib.mkIf (cfg.ai.enable && cfg.ai.mode == "remote") {
      systemd.mounts = [
        {
          type = "nfs";
          what = cfg.ai.remoteSource;
          where = cfg.ai.mountPoint;
          mountConfig = {
            Options = "${if cfg.ai.writable then "rw" else "ro"},noauto,x-systemd.mount-timeout=5,noatime,nodiratime,actimeo=60,soft,_netdev";
          };
        }
      ];
      systemd.automounts = [
        {
          where = cfg.ai.mountPoint;
          wantedBy = ["multi-user.target"];
          automountConfig = {TimeoutIdleSec = "600";};
        }
      ];
    })

    (lib.mkIf (cfg.ai.enable && cfg.ai.exportNfs) {
      services.nfs.server.exports = lib.mkOrder 900 (
        lib.concatMapStringsSep "\n" (ip: "${cfg.ai.mountPoint} ${ip}(rw,no_subtree_check)") cfg.ai.nfsClientIps
      );
    })

    # ============================================================================
    # HERMES — AppData for local editing
    # ============================================================================
    (lib.mkIf (cfg.hermes.enable && cfg.hermes.exportNfs) {
      assertions = [
        {
          assertion = cfg.hermes.nfsClientIps != [];
          message = "my.mounts.hermes.exportNfs requires at least one entry in my.mounts.hermes.nfsClientIps";
        }
      ];
    })

    (lib.mkIf (cfg.hermes.enable && cfg.hermes.mode == "local") {
      # Tmpfiles are managed in hermes.nix directly since it requires the hermes user/group to exist
      systemd.mounts = [
        {
          type = "none";
          what = cfg.hermes.localPath;
          where = cfg.hermes.mountPoint;
          mountConfig.Options = "bind";
          after = ["zfs-mount.service"];
          requires = ["zfs-mount.service"];
          wantedBy = ["multi-user.target"];
        }
      ];
    })

    (lib.mkIf (cfg.hermes.enable && cfg.hermes.mode == "remote") {
      systemd.mounts = [
        {
          type = "nfs";
          what = cfg.hermes.remoteSource;
          where = cfg.hermes.mountPoint;
          mountConfig = {
            Options = "${if cfg.hermes.writable then "rw" else "ro"},noauto,x-systemd.mount-timeout=5,noatime,nodiratime,actimeo=60,soft,_netdev";
          };
        }
      ];
      systemd.automounts = [
        {
          where = cfg.hermes.mountPoint;
          wantedBy = ["multi-user.target"];
          automountConfig = {TimeoutIdleSec = "600";};
        }
      ];
    })

    (lib.mkIf (cfg.hermes.enable && cfg.hermes.exportNfs) {
      services.nfs.server.exports = lib.mkOrder 900 (
        lib.concatMapStringsSep "\n" (ip: "${cfg.hermes.mountPoint} ${ip}(rw,no_subtree_check,all_squash,anonuid=1000,anongid=100)") cfg.hermes.nfsClientIps
      );
    })

    # ============================================================================
    # MEDIA
    # ============================================================================
    (lib.mkIf (cfg.media.enable && cfg.media.mode == "remote") {
      systemd.mounts = [
        {
          type = "nfs";
          what = "${servers.media_server}:/mnt/media";
          where = cfg.media.mountPoint;
          mountConfig = {
            Options = "${if cfg.media.writable then "rw" else "ro"},noauto,x-systemd.mount-timeout=5,noatime,nodiratime,actimeo=60,soft,_netdev";
          };
        }
      ];
      systemd.automounts = [
        {
          where = cfg.media.mountPoint;
          wantedBy = ["multi-user.target"];
          automountConfig = {TimeoutIdleSec = "600";};
        }
      ];
    })
    (lib.mkIf (cfg.media.enable && cfg.media.mode == "local") {
      systemd.mounts = [
        {
          type = "none";
          what = cfg.media.localPath;
          where = cfg.media.mountPoint;
          mountConfig.Options = "bind";
          after = ["zfs-mount.service"];
          requires = ["zfs-mount.service"];
          wantedBy = ["multi-user.target"];
        }
      ];
    })

    # ============================================================================
    # VAULT
    # ============================================================================
    (lib.mkIf (cfg.vault.enable && cfg.vault.mode == "remote") {
      systemd.mounts = [
        {
          type = "nfs";
          what = "${servers.nas}:/mnt/vault";
          where = cfg.vault.mountPoint;
          mountConfig = {Options = "rw,noauto,x-systemd.mount-timeout=5,noatime,nodiratime,actimeo=60,soft,_netdev";};
        }
      ];
      systemd.automounts = [
        {
          where = cfg.vault.mountPoint;
          wantedBy = ["multi-user.target"];
          automountConfig = {TimeoutIdleSec = "600";};
        }
      ];
    })
    (lib.mkIf (cfg.vault.enable && cfg.vault.mode == "local") {
      systemd.mounts = [
        {
          type = "none";
          what = cfg.vault.localPath;
          where = cfg.vault.mountPoint;
          mountConfig.Options = "bind";
          after = ["zfs-mount.service"];
          requires = ["zfs-mount.service"];
          wantedBy = ["multi-user.target"];
        }
      ];
    })

    # ============================================================================
    # BACKUP
    # ============================================================================
    (lib.mkIf (cfg.backup.enable && cfg.backup.mode == "remote") {
      systemd.mounts = [
        {
          type = "nfs";
          what = "${servers.nas}:/volume1/backup";
          where = cfg.backup.mountPoint;
          mountConfig = {Options = "rw,noauto,x-systemd.mount-timeout=5,noatime,nodiratime,actimeo=60,soft,_netdev";};
        }
      ];
      systemd.automounts = [
        {
          where = cfg.backup.mountPoint;
          wantedBy = ["multi-user.target"];
          automountConfig = {TimeoutIdleSec = "600";};
        }
      ];
    })
    (lib.mkIf (cfg.backup.enable && cfg.backup.mode == "local") {
      systemd.mounts = [
        {
          type = "none";
          what = cfg.backup.localPath;
          where = cfg.backup.mountPoint;
          mountConfig.Options = "bind";
          after = ["zfs-mount.service"];
          requires = ["zfs-mount.service"];
          wantedBy = ["multi-user.target"];
        }
      ];
    })

    # ============================================================================
    # LEGACY COMPATIBILITY
    # ============================================================================
    (lib.mkIf cfg.legacyPaths.enable {
      systemd.mounts = [
        {
          type = "nfs";
          what = "${servers.legacy_nas}:/volume1/media";
          where = "/mnt/well-of-mimir/media";
          mountConfig = {Options = "ro,noauto,x-systemd.mount-timeout=5,noatime,nodiratime,actimeo=60,soft,_netdev";};
        }
      ];
      systemd.automounts = [
        {
          where = "/mnt/well-of-mimir/media";
          wantedBy = ["multi-user.target"];
          automountConfig = {TimeoutIdleSec = "600";};
        }
      ];

      systemd.tmpfiles.rules = [
        "d /mnt/well-of-mimir 0755 root root -"
      ];
    })
  ];
}
