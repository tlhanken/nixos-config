> **⚠️ AI-Generated Content Disclaimer**
>
> This guide was generated with the assistance of artificial intelligence. While efforts have been made to ensure accuracy, please review all commands and configurations carefully before applying them to your system. Always maintain proper backups and verify information against official documentation.

# Disko Migration Guide for Sleipnir

This guide covers migrating the sleipnir host from imperative disk configuration to declarative disk management using disko.

## Table of Contents
1. [What is Disko?](#what-is-disko)
2. [Current State Analysis](#current-state-analysis)
3. [Why Migrate to Disko?](#why-migrate-to-disko)
4. [Prerequisites](#prerequisites)
5. [Migration Strategy](#migration-strategy)
6. [Step-by-Step Migration](#step-by-step-migration)
7. [Configuration Examples](#configuration-examples)
8. [Critical Caveats](#critical-caveats)
9. [Rollback Strategy](#rollback-strategy)
10. [Post-Migration Verification](#post-migration-verification)

## What is Disko?

Disko is a declarative disk partitioning and formatting tool for NixOS that allows you to:
- Define your entire disk layout in Nix configuration
- Automatically partition, format, and mount filesystems
- Version control your disk configuration
- Reproduce identical disk layouts across machines
- Integrate seamlessly with NixOS installation and deployment

Repository: https://github.com/nix-community/disko

## Current State Analysis

**Sleipnir's Current Configuration** (from `hardware-configuration.nix`):

```
Root:  /dev/disk/by-uuid/26623eea-916e-487a-9045-768756b78b61 (ext4)
Boot:  /dev/disk/by-uuid/4CA5-3E69 (vfat, ~512MB typical)
Swap:  /dev/disk/by-uuid/8e27e6f3-5e3a-4450-8827-736ad6b28f4b
```

**Key Observations**:
- Currently using ext4 filesystem (not ZFS)
- Standard UEFI boot with systemd-boot
- Has existing ZFS support modules (`customBoot.enable`) but not currently activated
- ZFS services configured (auto-scrub, auto-snapshot) waiting to be enabled
- Docker configured to use ZFS storage driver when ZFS is active

**Decision Point**: You have ZFS infrastructure ready but are currently on ext4. Consider whether to:
- **Option A**: Migrate to disko + ext4 (simpler, keep current filesystem)
- **Option B**: Migrate to disko + ZFS (leverage existing ZFS modules, gain snapshots/scrubbing)

## Why Migrate to Disko?

**Benefits**:
1. **Declarative disk management** - Disk layout lives in version control
2. **Reproducibility** - Easily recreate disk setup on new machines or after disasters
3. **Automated installation** - Can reinstall entire system from scratch with one command
4. **Consistency** - Same disk config across multiple hosts
5. **ZFS benefits** (if choosing ZFS):
   - Automatic snapshots (already configured in `zfs-services.nix`)
   - Data integrity checking with auto-scrub
   - Copy-on-write filesystem
   - Compression and deduplication

**Tradeoffs**:
- Requires full reinstallation (DATA LOSS)
- More complex initial setup
- ZFS has higher memory requirements (~1GB RAM per 1TB storage)
- Requires backup and restore workflow

## Prerequisites

### Critical: Data Backup

**⚠️ DISKO WILL DESTROY ALL DATA ON TARGET DISKS ⚠️**

Before proceeding:

1. **Backup all data** from sleipnir:
   ```bash
   # Identify important data
   du -sh /home/*

   # Backup to external drive or network storage
   rsync -avP /home/ /mnt/backup/home/
   rsync -avP /etc/nixos/ /mnt/backup/etc-nixos/

   # Backup any application data
   # - Docker volumes: /var/lib/docker
   # - Databases, media libraries, etc.
   ```

2. **Document current setup**:
   ```bash
   # Save partition layout
   lsblk -f > ~/disk-layout-backup.txt
   fdisk -l >> ~/disk-layout-backup.txt

   # Save mount points
   mount > ~/mounts-backup.txt

   # List all UUIDs
   blkid > ~/blkid-backup.txt
   ```

3. **Verify backups are complete and accessible**

4. **Have NixOS installation media ready** (USB stick with NixOS installer)

### Identify Target Disk

```bash
# List all disks
lsblk

# Identify the main disk (likely /dev/nvme0n1 or /dev/sda)
# For sleipnir, check the current root device:
df -h /
```

**Common disk paths**:
- NVMe: `/dev/nvme0n1`
- SATA/SSD: `/dev/sda`
- For this guide, we'll use `/dev/nvme0n1` based on sleipnir's kernel modules

## Migration Strategy

**Recommended Approach**: Clean Installation

Since disko manages the entire disk lifecycle, the safest approach is:

1. Add disko configuration to the repository (but don't activate yet)
2. Boot from NixOS installation media
3. Use disko to partition and format the disk
4. Install NixOS with the new configuration
5. Restore data from backups

**Cannot do in-place migration** - Disko needs exclusive control of the disk.

## Step-by-Step Migration

### Phase 1: Prepare Disko Configuration

#### 1.1: Add Disko to Flake Inputs

Edit `flake.nix`:

```nix
{
  description = "Trevor's NixOS devices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Add disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.blueprint { inherit inputs; };
}
```

Update flake:
```bash
nix flake lock
```

#### 1.2: Create Disko Configuration

Create `hosts/sleipnir/disko-config.nix` (see [Configuration Examples](#configuration-examples) below for full examples).

#### 1.3: Update Sleipnir Configuration

Edit `hosts/sleipnir/configuration.nix`:

```nix
{ pkgs, inputs, ... }:
{
  imports = [
    inputs.self.modules.bootstrap.bootstrap
    inputs.self.modules.bootstrapinstall.install
    inputs.self.modules.desktop.desktop
    inputs.self.modules.common.common
    inputs.disko.nixosModules.disko  # Add disko module
    ./disko-config.nix                # Import disk config
    # Remove or comment out old hardware-configuration.nix
    # ./hardware-configuration.nix
  ];

  # ... rest of configuration

  # If using ZFS, enable the custom boot option:
  # customBoot.enable = true;  # Only for ZFS setup
}
```

#### 1.4: Test Configuration Locally (Optional)

Before rebooting, test that the configuration builds:

```bash
# This won't apply the disk changes, just checks syntax
nix flake check
nixos-rebuild build --flake .#nixosConfigurations.sleipnir
```

### Phase 2: Boot Installation Media

1. **Create NixOS installation USB**:
   ```bash
   # On another machine
   wget https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso
   dd if=latest-nixos-minimal-x86_64-linux.iso of=/dev/sdX bs=4M status=progress
   ```

2. **Boot sleipnir from USB** and connect to network:
   ```bash
   # If using WiFi
   sudo systemctl start wpa_supplicant
   wpa_cli
   > add_network
   > set_network 0 ssid "YourSSID"
   > set_network 0 psk "YourPassword"
   > enable_network 0
   > quit

   # Test connectivity
   ping google.com
   ```

### Phase 3: Partition with Disko

3. **Clone your configuration**:
   ```bash
   # Install git in live environment
   nix-shell -p git

   # Clone repo
   git clone https://github.com/your-username/nixos-config.git
   cd nixos-config
   ```

4. **Run Disko to partition disk**:
   ```bash
   # ⚠️ POINT OF NO RETURN - THIS DESTROYS DATA ⚠️

   # Partition and format the disk
   sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko \
     -- --mode disko hosts/sleipnir/disko-config.nix

   # This will:
   # - Partition the disk according to your config
   # - Format filesystems
   # - Mount everything under /mnt
   ```

5. **Verify mounts**:
   ```bash
   lsblk
   mount | grep /mnt

   # Should see:
   # /dev/nvmeXnYpZ on /mnt type ext4/zfs (...)
   # /dev/nvmeXnYpZ on /mnt/boot type vfat (...)
   ```

### Phase 4: Install NixOS

6. **Generate hardware config** (optional, disko handles most of it):
   ```bash
   nixos-generate-config --no-filesystems --root /mnt
   # The --no-filesystems flag prevents overwriting disko config
   ```

7. **Copy configuration to /mnt**:
   ```bash
   mkdir -p /mnt/etc/nixos
   cp -r . /mnt/etc/nixos/nixos-config
   ```

8. **Install NixOS**:
   ```bash
   cd /mnt/etc/nixos/nixos-config

   # Install the system
   sudo nixos-install --flake .#nixosConfigurations.sleipnir

   # Set root password when prompted
   # Set user password if needed
   ```

9. **Reboot**:
   ```bash
   reboot
   ```

### Phase 5: Post-Installation

10. **Restore data**:
    ```bash
    # After booting into new system
    sudo rsync -avP /mnt/backup/home/ /home/

    # Restore application data as needed
    ```

11. **Verify ZFS services** (if using ZFS):
    ```bash
    systemctl status zfs-scrub.timer
    systemctl status zfs-snapshot.timer
    zfs list
    ```

## Configuration Examples

### Option A: Disko + EXT4 (Simple Migration)

Create `hosts/sleipnir/disko-config.nix`:

```nix
{ ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";  # Adjust to your disk
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };
            swap = {
              size = "16G";  # Adjust to your needs (typically RAM size)
              content = {
                type = "swap";
                randomEncryption = true;  # Optional: encrypted swap
                resumeDevice = false;     # Set true if using hibernation
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
```

**In `configuration.nix`**:
- Keep `boot.loader.systemd-boot.enable = true;`
- No need to enable `customBoot.enable`

### Option B: Disko + ZFS (Advanced, Recommended for Long-term)

Create `hosts/sleipnir/disko-config.nix`:

```nix
{ ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };
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
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "true";
          acltype = "posixacl";
          xattr = "sa";
          atime = "off";
        };
        mountpoint = null;

        datasets = {
          # Root dataset
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              mountpoint = "legacy";
            };
          };

          # Home with snapshots
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };

          # Nix store - no snapshots needed
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "false";
              atime = "off";
            };
          };

          # Docker volumes
          docker = {
            type = "zfs_fs";
            mountpoint = "/var/lib/docker";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };
    };
  };
}
```

**In `configuration.nix`** for ZFS:
```nix
{
  # Enable ZFS boot configuration
  customBoot.enable = true;

  # Set hostId (required for ZFS)
  networking.hostId = "52cad215";  # Already set for sleipnir

  # Keep systemd-boot disabled (GRUB handles ZFS)
  boot.loader.systemd-boot.enable = false;
}
```

### Option C: Disko + ZFS + Encryption (Maximum Security)

For encrypted ZFS root:

```nix
{ ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                passwordFile = "/tmp/secret.key";  # Use during install
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                };
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        # ... same as Option B
      };
    };
  };
}
```

**Note**: Encryption requires entering password at boot. Create `/tmp/secret.key` during installation:
```bash
echo "your-strong-passphrase" > /tmp/secret.key
```

## Critical Caveats

### ⚠️ Data Loss Warnings

1. **Disko WILL destroy all data** on the target disk
2. **No in-place migration** - requires full reinstall
3. **Backup everything important** before proceeding
4. **Test restore process** before wiping disk

### ZFS-Specific Considerations

1. **Memory Requirements**:
   - ZFS needs ~1GB RAM per 1TB of storage
   - Check: `free -h` before choosing ZFS
   - Sleipnir should have adequate RAM for typical setups

2. **Boot Process**:
   - ZFS root requires GRUB (not systemd-boot)
   - Must set `networking.hostId` (already configured)
   - Cannot use ZFS for `/boot` partition (use vfat)

3. **Dataset Layout**:
   - Separate datasets for `/`, `/home`, `/nix` recommended
   - Allows independent snapshot policies
   - Can exclude `/nix` from snapshots (saves space)

4. **Scrub Frequency**:
   - Auto-scrub checks data integrity weekly
   - Can be intensive on older hardware
   - Adjust in `modules/common/utils/zfs-services.nix` if needed

### Disko-Specific Issues

1. **Device Names**:
   - `/dev/nvme0n1` vs `/dev/sda` - verify your disk name
   - Use `lsblk` to confirm before running disko

2. **Partition Sizes**:
   - ESP (boot): 512M minimum, 1GB safer for multiple generations
   - Swap: Typically = RAM size (16GB example above)
   - Adjust percentages if you need specific sizes

3. **Blueprint Integration**:
   - Disko config should live in host directory
   - Import via `./disko-config.nix` not through Blueprint modules
   - Blueprint doesn't auto-discover disko configs

### Installation Media Challenges

1. **Network Access**:
   - Need working network to clone repo and fetch packages
   - WiFi setup in live environment can be tricky
   - Ethernet is easier if available

2. **Flake Evaluation**:
   - Installation media may have older Nix version
   - May need `--experimental-features "nix-command flakes"`

3. **Disk Detection**:
   - Some NVMe drives need specific kernel modules
   - Verify `lsblk` shows your disk before proceeding

## Rollback Strategy

### If Installation Fails

1. **Keep old hardware-configuration.nix**:
   ```bash
   # Before migration, save a copy outside the repo
   cp hosts/sleipnir/hardware-configuration.nix ~/hardware-configuration.nix.backup
   ```

2. **Restore from backup**:
   - Boot from installation media again
   - Manually recreate old partition scheme
   - Restore data from backups
   - Use saved hardware-configuration.nix

3. **Git revert**:
   ```bash
   # If disko config causes issues, revert
   git revert <commit-hash>
   git push
   ```

### If System Doesn't Boot

1. **Boot from installation media**
2. **Mount filesystems**:
   ```bash
   # For ext4
   mount /dev/nvme0n1p3 /mnt
   mount /dev/nvme0n1p1 /mnt/boot

   # For ZFS
   zpool import -f zroot
   mount -t zfs zroot/root /mnt
   mount -t zfs zroot/home /mnt/home
   mount -t zfs zroot/nix /mnt/nix
   mount /dev/nvme0n1p1 /mnt/boot
   ```

3. **Chroot and fix**:
   ```bash
   nixos-enter --root /mnt
   # Fix configuration issues
   nixos-rebuild switch --flake /etc/nixos/nixos-config#nixosConfigurations.sleipnir
   exit
   reboot
   ```

## Post-Migration Verification

### Essential Checks

1. **Verify boot process**:
   ```bash
   systemctl status
   journalctl -b  # Check boot logs
   ```

2. **Check filesystems**:
   ```bash
   df -h
   lsblk -f

   # For ZFS
   zpool status
   zfs list
   zfs get all zroot
   ```

3. **Verify services**:
   ```bash
   # ZFS auto-services (if using ZFS)
   systemctl status zfs-scrub.timer
   systemctl status zfs-snapshot.timer

   # Docker (should use ZFS storage)
   docker info | grep "Storage Driver"
   ```

4. **Test rebuild**:
   ```bash
   sudo nixos-rebuild test --flake /etc/nixos/nixos-config#nixosConfigurations.sleipnir
   ```

5. **Check disk performance** (optional):
   ```bash
   # Sequential read/write test
   dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync
   dd if=/tmp/test of=/dev/null bs=1M
   ```

### ZFS-Specific Verification

```bash
# Check compression is working
zfs get compression,compressratio zroot

# Verify snapshots are being created
zfs list -t snapshot

# Test snapshot creation
zfs snapshot zroot/home@test
zfs list -t snapshot
zfs destroy zroot/home@test

# Run manual scrub test
zpool scrub zroot
zpool status  # Check progress
```

### Configuration Validation

```bash
# Ensure configuration matches disko
cat /etc/fstab  # Should be minimal with ZFS
mount | grep zroot  # Verify ZFS mounts

# Check that hardware-configuration.nix is not being used
grep hardware-configuration.nix hosts/sleipnir/configuration.nix
# Should be commented out or removed
```

## Additional Resources

- **Disko Documentation**: https://github.com/nix-community/disko
- **Disko Examples**: https://github.com/nix-community/disko/tree/master/example
- **ZFS on NixOS**: https://nixos.wiki/wiki/ZFS
- **Blueprint Documentation**: https://github.com/numtide/blueprint

## Next Steps After Migration

Once disko is working on sleipnir:

1. **Apply same pattern to other hosts**:
   - Create disko configs for gungnir, galar, well-of-mimir
   - Standardize disk layouts across fleet

2. **Implement encryption** (if not done initially):
   - Add LUKS encryption to disko config
   - Consider TPM2-based unlock for automatic boot

3. **Set up ZFS replication** (if using ZFS):
   - Use `zfs send/receive` for backups
   - Consider automated snapshot shipping to backup server

4. **Document custom layouts**:
   - If you have special partitioning needs, document in CLAUDE.md
   - Share successful patterns across hosts

## Troubleshooting

### Common Issues

**Issue**: "cannot import 'zroot': pool already imported"
```bash
# Solution: Force import
zpool import -f zroot
```

**Issue**: Disko fails with "device is busy"
```bash
# Solution: Unmount and try again
umount -R /mnt
zpool export zroot  # if using ZFS
```

**Issue**: Boot fails with "no such device"
```bash
# Solution: Rebuild initrd
nixos-enter --root /mnt
nixos-rebuild boot
```

**Issue**: systemd-boot still enabled with ZFS
```bash
# Solution: Ensure in configuration.nix:
boot.loader.systemd-boot.enable = false;
customBoot.enable = true;  # Enables GRUB with ZFS
```
