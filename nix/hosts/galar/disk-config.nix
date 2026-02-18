{
  disk = {
    boot = {
      type = "disk";
      device = "/dev/nvme0n1";
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
          zfs = {
            end = "-24G";
            content = {
              type = "zfs";
              pool = "zroot";
            };
            priority = 3;
          };
          encryptedSwap = {
            size = "8G";
            content = {
              type = "swap";
              randomEncryption = true;
              priority = 100; # prefer to encrypt as long as we have space for it
            };
          };
          plainSwap = {
            size = "100%";
            content = {
              type = "swap";
              discardPolicy = "both";
              resumeDevice = true; # resume from hibernation from this device
            };
          };
        };
      };
    };
    vault = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zvault";
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
              members = ["boot"];
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
        reserved = {
          type = "zfs_fs";
          options.refreservation = "10G";
          options.mountpoint = "none";
        };
      };
    };
    zvault = {
      type = "zpool";
      mode = {
         topology = {
           type = "topology";
           vdev = [
             {
               members = [ "vault" ];
             }
           ];
         };
      };
      rootFsOptions = {
        compression = "lz4";
        "com.sun:auto-snapshot" = "false";
        recordsize = "1M";
        atime = "off";
        xattr = "sa";
      };
      mountpoint = "/mnt/vault";
    };
  };
}
