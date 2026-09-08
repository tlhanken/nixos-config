{
  disk = {
    nvme0 = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-WD_BLACK_SN7100_4TB_25500V800128";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
            priority = 1;
          };
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
            priority = 2;
          };
          swap = {
            size = "128G";
            content = {
              type = "swap";
              discardPolicy = "both";
            };
            priority = 3;
          };
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
            priority = 4;
          };
        };
      };
    };
    nvme1 = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-WD_BLACK_SN7100_4TB_254223800645";
      content = {
        type = "gpt";
        partitions = {
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };
  };
  zpool = {
    zroot = {
      type = "zpool";
      mode = {
        topology = {
          type = "topology";
          cache = [];
          vdev = [
            {
              # Striped VDEV (RAID 0) across both nvme drives for max performance
              members = [ "nvme0" "nvme1" ];
            }
          ];
        };
      };
      rootFsOptions = {
        # ashift = "12";
        xattr = "sa";
        compression = "lz4";
        atime = "off";
        recordsize = "64K";
        "com.sun:auto-snapshot" = "true";
      };
      mountpoint = "/";
      datasets = {
        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options."com.sun:auto-snapshot" = "false";
        };
        var = {
          type = "zfs_fs";
          mountpoint = "/var";
        };
        home = {
          type = "zfs_fs";
          mountpoint = "/home";
        };
        vault = {
          type = "zfs_fs";
          mountpoint = "/mnt/local/vault";
        };
        ai = {
          type = "zfs_fs";
          mountpoint = "/mnt/local/ai";
          options."com.sun:auto-snapshot" = "false";
        };
        appdata = {
          type = "zfs_fs";
          mountpoint = "/mnt/local/appdata";
        };
        reserved = {
          type = "zfs_fs";
          options.refreservation = "10G";
          options.mountpoint = "none";
        };
      };
    };
  };
}
