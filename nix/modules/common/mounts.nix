{ config, lib, pkgs, ... }:

let
  cfg = config.my.mounts;
  servers = {
    nas = "well-of-mimir.fenrir-altered.ts.net";
    media_server = "galar.fenrir-altered.ts.net";
  };
  anyNfsEnabled =
    (cfg.media.enable && cfg.media.mode == "remote") ||
    (cfg.vault.enable && cfg.vault.mode == "remote") ||
    (cfg.backup.enable && cfg.backup.mode == "remote") ||
    cfg.legacyPaths.enable;

  # Helper to define the enhanced mount options
  mkMountOpt = name: defaultLocalPath: {
    enable = lib.mkEnableOption "${name} Mount";
    writable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to mount read-write (remote mode only; server must also export rw).";
    };
    mode = lib.mkOption {
      type = lib.types.enum [ "remote" "local" ];
      default = "remote";
      description = "Whether to mount via NFS (remote) or Bind Mount (local)";
    };
    localPath = lib.mkOption {
      type = lib.types.path;
      default = defaultLocalPath;
      description = "Path to the local source directory (used when mode = 'local')";
    };
  };
in
{
  options.my.mounts = {
    media = mkMountOpt "Media" "/mnt/local/media";
    vault = mkMountOpt "Vault" "/mnt/local/vault";
    backup = mkMountOpt "Backup" "/mnt/local/backup";
    
    legacyPaths = {
      enable = lib.mkEnableOption "Legacy Mount Paths (/mnt/well-of-mimir/...)";
    };
  };

  config = lib.mkMerge [
    # ============================================================================
    # NFS SUPPORT (auto-enabled when any remote mount is active)
    # ============================================================================
    (lib.mkIf anyNfsEnabled {
      boot.supportedFilesystems = [ "nfs" ];
      environment.systemPackages = [ pkgs.nfs-utils ];
    })

    # ============================================================================
    # MEDIA
    # ============================================================================
    (lib.mkIf (cfg.media.enable && cfg.media.mode == "remote") {
      systemd.mounts = [{
        type = "nfs";
        what = "${servers.media_server}:/mnt/media";
        where = "/mnt/media";
        mountConfig = { Options = "${if cfg.media.writable then "rw" else "ro"},noauto,timeo=14,_netdev"; };
      }];
      systemd.automounts = [{
        where = "/mnt/media";
        wantedBy = [ "multi-user.target" ];
        automountConfig = { TimeoutIdleSec = "600"; };
      }];
    })
    (lib.mkIf (cfg.media.enable && cfg.media.mode == "local") {
      systemd.mounts = [{
        type = "none";
        what = cfg.media.localPath;
        where = "/mnt/media";
        mountConfig.Options = "bind";
        after = [ "zfs-mount.service" ];
        requires = [ "zfs-mount.service" ];
        wantedBy = [ "multi-user.target" ];
      }];
    })

    # ============================================================================
    # VAULT
    # ============================================================================
    (lib.mkIf (cfg.vault.enable && cfg.vault.mode == "remote") {
      systemd.mounts = [{
        type = "nfs";
        what = "${servers.media_server}:/mnt/vault";
        where = "/mnt/vault";
        mountConfig = { Options = "rw,noauto,timeo=14,_netdev"; };
      }];
      systemd.automounts = [{
        where = "/mnt/vault";
        wantedBy = [ "multi-user.target" ];
        automountConfig = { TimeoutIdleSec = "600"; };
      }];
    })
    (lib.mkIf (cfg.vault.enable && cfg.vault.mode == "local") {
      systemd.mounts = [{
        type = "none";
        what = cfg.vault.localPath;
        where = "/mnt/vault";
        mountConfig.Options = "bind";
        after = [ "zfs-mount.service" ];
        requires = [ "zfs-mount.service" ];
        wantedBy = [ "multi-user.target" ];
      }];
    })

    # ============================================================================
    # BACKUP
    # ============================================================================
    (lib.mkIf (cfg.backup.enable && cfg.backup.mode == "remote") {
      systemd.mounts = [{
        type = "nfs";
        what = "${servers.nas}:/volume1/backup";
        where = "/mnt/backup";
        mountConfig = { Options = "rw,noauto,timeo=14,_netdev"; };
      }];
      systemd.automounts = [{
        where = "/mnt/backup";
        wantedBy = [ "multi-user.target" ];
        automountConfig = { TimeoutIdleSec = "600"; };
      }];
    })
    (lib.mkIf (cfg.backup.enable && cfg.backup.mode == "local") {
      systemd.mounts = [{
        type = "none";
        what = cfg.backup.localPath;
        where = "/mnt/backup";
        mountConfig.Options = "bind";
        after = [ "zfs-mount.service" ];
        requires = [ "zfs-mount.service" ];
        wantedBy = [ "multi-user.target" ];
      }];
    })

    # ============================================================================
    # LEGACY COMPATIBILITY
    # ============================================================================
    (lib.mkIf cfg.legacyPaths.enable {
      # 1. Legacy Media: /mnt/well-of-mimir/media -> NAS via NFS
      # This is ALWAYS an NFS mount, even on Galar (as requested for path consistency/migration)
      systemd.mounts = [{
        type = "nfs";
        what = "${servers.nas}:/volume1/media";
        where = "/mnt/well-of-mimir/media";
        mountConfig = { Options = "ro,noauto,timeo=14,_netdev"; };
      }];
      systemd.automounts = [{
        where = "/mnt/well-of-mimir/media";
        wantedBy = [ "multi-user.target" ];
        automountConfig = { TimeoutIdleSec = "600"; };
      }];
      
      # Ensure parent directory exists
      systemd.tmpfiles.rules = [
        "d /mnt/well-of-mimir 0755 root root -"
      ];
    })
  ];
}
