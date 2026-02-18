> **⚠️ AI-Generated Content Disclaimer**
>
> This guide was generated with the assistance of artificial intelligence. While efforts have been made to ensure accuracy, please review all commands and configurations carefully before applying them to your system. Always maintain proper backups and verify information against official documentation.

# NixOS Installation Guide

This guide covers creating bootable USB installation media and deploying NixOS configurations from this repository to new or existing devices.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Creating Installation Media](#creating-installation-media)
3. [Booting Installation Environment](#booting-installation-environment)
4. [Installation Scenarios](#installation-scenarios)
5. [Scenario A: Deploy Existing Configuration](#scenario-a-deploy-existing-configuration-to-new-hardware)
6. [Scenario B: Set Up New Host](#scenario-b-set-up-brand-new-host)
7. [Partitioning Options](#partitioning-options)
8. [Post-Installation](#post-installation)
9. [Troubleshooting](#troubleshooting)

## Prerequisites

### What You'll Need

- **Source machine**: Computer with internet access to prepare USB
- **USB flash drive**: Minimum 2GB (8GB+ recommended)
- **Target machine**: The device you're installing NixOS onto
- **Network access**: Ethernet cable or WiFi credentials
- **This repository**: Either cloned locally or accessible via GitHub

### Important Notes

⚠️ **The installation process will ERASE ALL DATA on the target machine's disk**

✓ Back up any important data before proceeding
✓ Verify you're targeting the correct disk
✓ Have passwords ready (user password, encryption password if using)

## Creating Installation Media

There are two approaches for creating installation media:

### Approach A: Build Custom ISO from This Repository (Recommended)

This creates a custom NixOS ISO that includes your repository's configuration, making installation faster and more streamlined.

**Prerequisites**:
- A Linux machine with Nix installed (or an existing NixOS system)
- This repository cloned locally
- Sufficient disk space (~5GB for build artifacts)

**Status**: ⚠️ **Implementation Pending** - See [Custom ISO Implementation Gameplan](#custom-iso-implementation-gameplan) below for required flake changes.

Once implemented, you'll be able to build a custom ISO with:

```bash
# Clone this repository
git clone https://github.com/YOUR-USERNAME/nixos-config.git
cd nixos-config

# Build custom installer ISO (command will be available after implementation)
nix build .#installer-iso

# The ISO will be in: result/iso/nixos-*.iso
```

### Approach B: Download Standard NixOS ISO (Current Method)

Download the official NixOS ISO and clone this repository during installation.

**On your source machine**:

```bash
# Download the latest minimal ISO (faster, smaller)
wget https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso

# Alternative: Download graphical ISO (includes desktop, easier for WiFi setup)
wget https://channels.nixos.org/nixos-unstable/latest-nixos-gnome-x86_64-linux.iso

# Verify download (optional but recommended)
wget https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso.sha256
sha256sum -c latest-nixos-minimal-x86_64-linux.iso.sha256
```

**ISO Options**:
- **Minimal**: ~900MB, command-line only, requires manual WiFi setup
- **Graphical (GNOME)**: ~3GB, includes GUI for easier network configuration

---

### Step 1: Identify USB Drive

```bash
# List all disks BEFORE inserting USB
lsblk

# Insert your USB drive, then list again
lsblk

# Identify the new device (typically /dev/sdb or /dev/sdc)
# Look for a device matching your USB drive's size
```

⚠️ **CRITICAL**: Double-check the device name. Using the wrong device will destroy data on that disk!

Example output:
```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 238.5G  0 disk           <- Your main disk
├─sda1   8:1    0   512M  0 part /boot
└─sda2   8:2    0   238G  0 part /
sdb      8:16   1  14.9G  0 disk           <- Your USB drive
```

### Step 2: Write ISO to USB

```bash
# Replace /dev/sdX with your actual USB device
# This command requires sudo/root privileges

# Unmount USB if it's mounted
sudo umount /dev/sdX*

# Write the ISO to USB
sudo dd if=latest-nixos-minimal-x86_64-linux.iso of=/dev/sdX bs=4M status=progress conv=fsync

# Wait for completion (may take 5-10 minutes)
# You'll see progress like: "900 MB (944 MB, 901 MiB) copied, 120 s, 7.5 MB/s"

# Verify write completed
sync
```

**Alternative: Using `cat` (simpler syntax)**:
```bash
sudo cat latest-nixos-minimal-x86_64-linux.iso > /dev/sdX
```

**Alternative: Using GUI tool (easier for beginners)**:
- Linux: Use **Etcher** (https://www.balena.io/etcher/) or **GNOME Disks**
- Windows: Use **Rufus** (https://rufus.ie/) or **Etcher**
- macOS: Use **Etcher** or `dd` command

### Step 3: Safely Remove USB

```bash
# Eject the USB drive
sudo eject /dev/sdX

# Or unmount it
sudo umount /dev/sdX*
```

Your installation USB is now ready!

## Booting Installation Environment

### Step 1: Boot from USB

1. **Insert USB** into target machine
2. **Power on** and enter boot menu:
   - Common keys: `F12`, `F11`, `F9`, `F8`, `Esc`, `Del`
   - For UEFI: May need to enable "Boot from USB" in BIOS settings
   - Some systems: Hold `Option/Alt` (Mac), `F2` (Dell), `F10` (HP)

3. **Select USB drive** from boot menu
4. **Wait for NixOS boot screen** to appear
5. **Select "NixOS Installer"** (first option, default)

### Step 2: Verify Boot

Once booted, you'll see a terminal prompt:
```
nixos@nixos:~$
```

Test basic functionality:
```bash
# Check you're running NixOS
uname -a

# List disks (verify your target disk is visible)
lsblk
```

### Step 3: Set Up Networking

#### Option A: Ethernet (Easiest)

```bash
# Plug in ethernet cable
# Network should work automatically

# Test connectivity
ping -c 3 google.com
```

#### Option B: WiFi (Minimal ISO)

```bash
# Start wpa_supplicant
sudo systemctl start wpa_supplicant

# Connect to network
sudo wpa_cli

# In wpa_cli interactive prompt:
> scan
> scan_results
> add_network
0
> set_network 0 ssid "YourNetworkName"
OK
> set_network 0 psk "YourPassword"
OK
> enable_network 0
OK
> quit

# Verify connection
ping -c 3 google.com

# Get IP address
ip addr show
```

#### Option C: WiFi (Graphical ISO)

Use the GNOME network manager GUI in the top-right corner.

### Step 4: Set Up Installation Environment

```bash
# Optional: Set larger console font (if text is too small)
setfont ter-v32n

# Optional: Set keyboard layout (default is US)
loadkeys de  # Example: German layout
# Other layouts: fr, uk, dvorak, etc.

# Become root (makes subsequent commands easier)
sudo -i
```

## Installation Scenarios

Choose your scenario:

- **Scenario A**: Deploy existing configuration (e.g., sleipnir) to new hardware
  - Use when: Replacing a machine, installing to identical hardware, cloning setup
  - Existing configs: `sleipnir` (fully configured)

- **Scenario B**: Set up a brand new host configuration
  - Use when: Adding gungnir, galar, or well-of-mimir to the fleet
  - Creates new configuration from scratch

## Scenario A: Deploy Existing Configuration to New Hardware

This installs an existing host configuration (like `sleipnir`) onto new hardware.

### A1: Identify Target Disk

```bash
# List all disks
lsblk

# Identify your target disk (e.g., /dev/nvme0n1 or /dev/sda)
# Note: This disk will be COMPLETELY ERASED
```

### A2: Clone Repository

```bash
# Install git
nix-shell -p git

# Clone your repository
git clone https://github.com/YOUR-USERNAME/nixos-config.git
cd nixos-config

# Checkout specific branch if needed
# git checkout main
```

### A3: Partition Disk

Choose your partitioning method:

#### Option 1: Using Disko (if configured)

If the host has a `disko-config.nix` file:

```bash
# Check if disko config exists
ls hosts/sleipnir/disko-config.nix

# Edit disko config to match your disk device
nano hosts/sleipnir/disko-config.nix
# Change device = "/dev/nvme0n1" to your actual disk

# Run disko to partition and format
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko \
  -- --mode disko hosts/sleipnir/disko-config.nix

# Verify mounts
lsblk
mount | grep /mnt
```

#### Option 2: Manual Partitioning (if no disko)

See [Partitioning Options](#partitioning-options) section below for detailed manual steps.

### A4: Generate Hardware Configuration

```bash
# Generate hardware config for new hardware
# Use --no-filesystems if using disko
nixos-generate-config --no-filesystems --root /mnt

# Or without disko, let it detect filesystems:
nixos-generate-config --root /mnt

# This creates /mnt/etc/nixos/hardware-configuration.nix
# You'll need to copy relevant parts to your repo
```

### A5: Update Configuration for New Hardware

```bash
# Copy the generated hardware config to your repo
cp /mnt/etc/nixos/hardware-configuration.nix hosts/sleipnir/hardware-configuration.nix

# If using disko, you may only need kernel modules from hardware-configuration.nix
# Edit configuration to extract just the needed parts:
nano hosts/sleipnir/configuration.nix
```

Important items from `hardware-configuration.nix`:
- `boot.initrd.availableKernelModules` - Critical for boot
- `nixpkgs.hostPlatform` - Architecture (usually x86_64-linux)
- `hardware.cpu.intel.updateMicrocode` or `hardware.cpu.amd.updateMicrocode`

### A6: Copy Repository to Target

```bash
# Copy your repository to the target system
cp -r . /mnt/etc/nixos/nixos-config

# Or if you want it in a different location:
mkdir -p /mnt/home/tlhanken/nixos-config
cp -r . /mnt/home/tlhanken/nixos-config
```

### A7: Install NixOS

```bash
# Install from your flake configuration
cd /mnt/etc/nixos/nixos-config

sudo nixos-install --flake .#nixosConfigurations.sleipnir

# The installer will:
# - Build the system configuration
# - Install to /mnt
# - Set up bootloader
# - Prompt for root password

# Set root password when prompted
# Password: ********
```

### A8: Reboot

```bash
# Installation complete!
reboot

# Remove USB drive during reboot
```

## Scenario B: Set Up Brand New Host

This creates a new host configuration (e.g., gungnir, galar, well-of-mimir).

### B1: Plan Your Host

Decide:
- **Hostname**: gungnir, galar, well-of-mimir, or custom name
- **User(s)**: Username(s) to create
- **Modules**: Which features to enable (desktop, apps, etc.)
- **Disk layout**: Partitioning scheme

### B2: Boot and Prepare (same as Scenario A)

Follow steps A1-A2 from Scenario A to boot installation media and clone repository.

### B3: Partition Disk

Choose your partitioning method:

#### Option 1: Create Disko Configuration (Recommended)

```bash
# Create disko config for new host
mkdir -p hosts/gungnir
nano hosts/gungnir/disko-config.nix
```

Copy a template from `DISKO_MIGRATION_GUIDE.md` or use this basic example:

```nix
{ ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";  # CHANGE THIS to your disk!
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
              size = "16G";
              content = {
                type = "swap";
                randomEncryption = true;
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

Run disko:
```bash
# Partition with disko
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko \
  -- --mode disko hosts/gungnir/disko-config.nix

# Verify mounts
mount | grep /mnt
```

#### Option 2: Manual Partitioning

See [Partitioning Options](#partitioning-options) section below.

### B4: Create Host Configuration

```bash
# Create configuration file
nano hosts/gungnir/configuration.nix
```

Use this template:

```nix
{ pkgs, inputs, ... }:
{
  imports = [
    inputs.self.modules.bootstrap.bootstrap
    inputs.self.modules.bootstrapinstall.install
    # Add other modules as needed:
    # inputs.self.modules.desktop.desktop      # For GUI
    # inputs.self.modules.common.common        # For Docker, auto-upgrade

    # If using disko:
    inputs.disko.nixosModules.disko
    ./disko-config.nix

    # If NOT using disko, generate and use hardware-configuration.nix:
    # ./hardware-configuration.nix
  ];

  # Set hostname
  networking.hostName = "gungnir";

  # Generate with: head -c 8 /etc/machine-id
  networking.hostId = "XXXXXXXX";  # TODO: Generate after first boot

  # Set system version
  system.stateVersion = "25.05";

  # Create user account
  users.users.yourusername = {
    isNormalUser = true;
    description = "Your Full Name";
    extraGroups = [
      "networkmanager"
      "wheel"  # Enables sudo
      # "docker"  # If using Docker
    ];
    # Generate with: mkpasswd -m sha-512
    hashedPassword = "$6$...";  # CHANGE THIS
    # Or use initialPassword for first login:
    # initialPassword = "changeme";
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable firmware updates
  services.fwupd.enable = true;
}
```

### B5: Create User Home-Manager Config (Optional)

```bash
# Create user directory
mkdir -p hosts/gungnir/users

# Create user config
nano hosts/gungnir/users/yourusername.nix
```

Template:
```nix
{ pkgs, inputs, ... }:
{
  imports = [ inputs.self.homeModules.home-shared ];

  # Add user-specific home-manager configuration here
  # Example:
  # home.packages = with pkgs; [
  #   firefox
  #   thunderbird
  # ];
}
```

### B6: Generate Hardware Configuration

```bash
# If using disko (only need kernel modules):
nixos-generate-config --no-filesystems --root /mnt

# If NOT using disko:
nixos-generate-config --root /mnt

# Copy to your host directory
cp /mnt/etc/nixos/hardware-configuration.nix hosts/gungnir/

# If using disko, extract only these sections from hardware-configuration.nix
# and add to your configuration.nix:
# - boot.initrd.availableKernelModules
# - boot.initrd.kernelModules (if any)
# - boot.kernelModules
# - nixpkgs.hostPlatform
# - hardware.cpu.*.updateMicrocode
```

### B7: Generate Host ID

```bash
# Generate a unique host ID for ZFS (even if not using ZFS yet)
head -c 8 /etc/machine-id

# Copy the output and update hosts/gungnir/configuration.nix:
# networking.hostId = "a1b2c3d4";  # Replace with generated value
```

### B8: Test Configuration Builds

```bash
# Copy repository to target
cp -r . /mnt/etc/nixos/nixos-config
cd /mnt/etc/nixos/nixos-config

# Test that configuration builds (optional but recommended)
nix --experimental-features "nix-command flakes" build \
  .#nixosConfigurations.gungnir

# If build succeeds, proceed with installation
```

### B9: Install NixOS

```bash
sudo nixos-install --flake .#nixosConfigurations.gungnir

# Set root password when prompted
# Installation may take 10-30 minutes depending on configuration
```

### B10: Commit Configuration

```bash
# Before rebooting, commit your new configuration
git add hosts/gungnir/
git commit -m "Add gungnir configuration"

# Push to repository (if you have network and GitHub access)
# git push origin main
```

### B11: Reboot

```bash
reboot
# Remove USB drive during reboot
```

## Partitioning Options

### Manual Partitioning (No Disko)

If not using disko, partition manually:

#### For UEFI Systems (Most Modern Computers)

```bash
# Identify disk (e.g., /dev/sda or /dev/nvme0n1)
lsblk

# Start partitioning tool
parted /dev/nvme0n1 -- mklabel gpt

# Create boot partition (512MB)
parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
parted /dev/nvme0n1 -- set 1 esp on

# Create swap partition (size = RAM size, e.g., 16GB)
parted /dev/nvme0n1 -- mkpart swap linux-swap 512MB 16GB

# Create root partition (rest of disk)
parted /dev/nvme0n1 -- mkpart root ext4 16GB 100%

# Format partitions
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
mkswap -L SWAP /dev/nvme0n1p2
mkfs.ext4 -L ROOT /dev/nvme0n1p3

# Mount filesystems
mount /dev/nvme0n1p3 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/nvme0n1p2

# Verify mounts
lsblk -f
mount | grep /mnt
```

#### For BIOS Systems (Older Computers)

```bash
# Create MBR partition table
parted /dev/sda -- mklabel msdos

# Create swap partition
parted /dev/sda -- mkpart primary linux-swap 1MB 16GB

# Create root partition
parted /dev/sda -- mkpart primary ext4 16GB 100%
parted /dev/sda -- set 2 boot on

# Format partitions
mkswap -L SWAP /dev/sda1
mkfs.ext4 -L ROOT /dev/sda2

# Mount filesystems
mount /dev/sda2 /mnt
swapon /dev/sda1
```

**Note**: BIOS systems use GRUB in MBR instead of systemd-boot. Update `configuration.nix`:
```nix
boot.loader.grub.enable = true;
boot.loader.grub.device = "/dev/sda";  # Not a partition!
boot.loader.systemd-boot.enable = false;
```

## Post-Installation

### First Boot

1. **Remove USB drive** before/during reboot
2. **Wait for bootloader** (GRUB or systemd-boot)
3. **Select NixOS** (first entry, default)
4. **Log in** with your user account

### Initial Configuration

```bash
# Set user password if you used initialPassword
passwd

# Generate host ID if not set during installation (ZFS requirement)
sudo head -c 8 /etc/machine-id
# Add to configuration.nix: networking.hostId = "value";

# Update configuration location
cd /etc/nixos/nixos-config  # or ~/nixos-config if you put it there

# Test rebuild
sudo nixos-rebuild test --flake .#nixosConfigurations.gungnir

# Apply permanently
sudo nixos-rebuild switch --flake .#nixosConfigurations.gungnir
```

### Set Up Development Environment

```bash
# If you have direnv configured (from home-manager)
cd /path/to/nixos-config
direnv allow

# This will activate the development shell automatically
```

### Push Configuration to GitHub

```bash
cd /etc/nixos/nixos-config

# Configure git if needed
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Commit any changes made during installation
git add .
git commit -m "Finalize gungnir installation"

# Push to GitHub
git push origin main
```

### Verify Installation

```bash
# Check system status
systemctl status

# Check disk usage
df -h

# Check mounted filesystems
mount

# Check network
ip addr
ping google.com

# Test rebuild functionality
sudo nixos-rebuild test --flake .#nixosConfigurations.gungnir
```

## Troubleshooting

### USB Boot Issues

**Problem**: Computer won't boot from USB

**Solutions**:
- Disable Secure Boot in BIOS/UEFI settings
- Try a different USB port (USB 2.0 ports often more reliable)
- Recreate USB with a different tool (try Etcher or Rufus)
- Verify ISO checksum was correct

**Problem**: "No operating system found" or immediate reboot

**Solutions**:
- USB may not be bootable - recreate with `dd conv=fsync`
- Some systems require "Legacy Boot" or "CSM" enabled
- Check BIOS boot order - USB should be first

### Network Issues

**Problem**: WiFi not working in minimal ISO

**Solutions**:
- Use ethernet cable if available
- Download graphical ISO with GUI network manager
- Try USB WiFi adapter if built-in WiFi unsupported
- Check wireless device exists: `ip link`

**Problem**: Can't connect to WPA2 Enterprise network

**Solutions**:
- WPA2 Enterprise is complex in minimal installer
- Use ethernet or mobile hotspot for installation
- Configure advanced WiFi after installation completes

### Partition Issues

**Problem**: "Device busy" when partitioning

**Solutions**:
```bash
# Unmount any mounted partitions
umount -R /mnt

# Stop swap
swapoff -a

# If using ZFS, export pool
zpool export zroot

# Retry partitioning
```

**Problem**: Wrong disk device name

**Solutions**:
```bash
# List all disks with details
lsblk -f
fdisk -l

# NVMe drives: /dev/nvme0n1, /dev/nvme1n1, etc.
# SATA drives: /dev/sda, /dev/sdb, etc.
# Virtual disks: /dev/vda, /dev/vdb (VMs)
```

### Installation Errors

**Problem**: "error: package ... does not support platform"

**Solutions**:
```bash
# Check architecture in configuration.nix matches hardware
nixpkgs.hostPlatform = "x86_64-linux";  # For Intel/AMD 64-bit
nixpkgs.hostPlatform = "aarch64-linux";  # For ARM 64-bit (Raspberry Pi, etc.)
```

**Problem**: Flake evaluation errors

**Solutions**:
```bash
# Check flake syntax
nix flake check

# Update flake inputs
nix flake update

# Try with specific nixpkgs version
nix --experimental-features "nix-command flakes" build \
  --override-input nixpkgs github:NixOS/nixpkgs/nixos-unstable \
  .#nixosConfigurations.gungnir
```

**Problem**: "hash mismatch" errors

**Solutions**:
```bash
# Update flake lock file
rm flake.lock
nix flake lock

# Clear Nix cache
nix-collect-garbage -d
```

### Boot Issues After Installation

**Problem**: System won't boot - "No bootable device"

**Solutions**:
- Boot from USB again
- Check boot partition is mounted at `/boot`
- Reinstall bootloader:
  ```bash
  mount /dev/nvme0n1p3 /mnt
  mount /dev/nvme0n1p1 /mnt/boot
  nixos-enter --root /mnt
  nixos-rebuild switch --flake /etc/nixos/nixos-config#nixosConfigurations.gungnir
  ```

**Problem**: Kernel panic or initrd errors

**Solutions**:
- Missing kernel modules in `boot.initrd.availableKernelModules`
- Re-generate hardware-configuration.nix and copy kernel modules
- Common needed modules:
  - NVMe: `"nvme"`
  - SATA: `"ahci"`, `"sd_mod"`
  - USB boot: `"usb_storage"`, `"usbhid"`

**Problem**: "Waiting for device to appear" timeout

**Solutions**:
- Wrong disk UUIDs in filesystems configuration
- If using disko, ensure device path is correct
- Check `/boot` UUID matches ESP partition

### Blueprint-Specific Issues

**Problem**: "module not found" errors

**Solutions**:
```bash
# Verify module path matches directory structure
# Example: inputs.self.modules.bootstrap.bootstrap
#          maps to: modules/bootstrap/bootstrap.nix

# Check flake outputs
nix flake show

# Rebuild flake
nix flake update
```

**Problem**: Home-manager module not found

**Solutions**:
```bash
# Ensure home-manager input is in flake.nix
# Verify user config imports: inputs.self.homeModules.home-shared
# Check module file exists: modules/home/home-shared.nix
```

## Quick Reference

### Essential Commands

```bash
# In live installer:
lsblk                                    # List disks
nixos-generate-config --root /mnt       # Generate hardware config
nixos-install --flake .#configName      # Install system

# After installation:
nixos-rebuild switch --flake .#configName   # Apply configuration
nixos-rebuild test --flake .#configName     # Test configuration
nh os switch .                              # Using nh helper
nh os test .                                # Test with nh

# Maintenance:
nix flake update                         # Update inputs
nix-collect-garbage -d                   # Clean old generations
```

### File Locations

```
/mnt/                           # Mount point during installation
/mnt/boot/                      # Boot partition mount
/mnt/etc/nixos/                 # Default config location
/etc/nixos/configuration.nix    # Traditional location (not used here)
/etc/nixos/hardware-configuration.nix  # Generated hardware config
```

### Disk Device Names

```
/dev/nvme0n1       # First NVMe drive
/dev/nvme0n1p1     # First partition on NVMe drive
/dev/sda           # First SATA drive
/dev/sda1          # First partition on SATA drive
/dev/vda           # Virtual disk (VMs)
```

## Additional Resources

- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **NixOS Installation**: https://nixos.org/manual/nixos/stable/#sec-installation
- **Disko Documentation**: https://github.com/nix-community/disko
- **Blueprint Framework**: https://github.com/numtide/blueprint
- **This Repo's Docs**: See `CLAUDE.md` and `DISKO_MIGRATION_GUIDE.md`

## Next Steps

After successful installation:

1. **Configure services**: Enable desktop, Docker, apps as needed
2. **Set up backups**: Especially if using ZFS
3. **Install applications**: Add to home-manager configuration
4. **Sync settings**: Push configuration to GitHub
5. **Document hardware**: Note any special requirements for future reference
6. **Test updates**: Run `nh os test .` before `nh os switch .`

Your new NixOS system is ready to use!

---

## Custom ISO Implementation Gameplan

This section outlines the steps needed to enable custom ISO generation from this repository.

### Overview

The goal is to create a custom NixOS installation ISO that:
- Includes this repository pre-installed
- Contains all the tools needed for installation (git, nixos-generators, etc.)
- Optionally includes commonly used packages to speed up installation
- Follows the Blueprint framework's auto-discovery pattern

### Implementation Approaches

#### Option 1: Using nixos-generators (Recommended)

**Advantages**:
- Simple flake integration
- Well-maintained by nix-community
- Supports multiple output formats (ISO, VM images, etc.)
- Easy to customize

**Required Changes**:

1. **Update `flake.nix`**:
   ```nix
   inputs = {
     # ... existing inputs ...
     nixos-generators.url = "github:nix-community/nixos-generators";
     nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
   };
   ```

2. **Create `hosts/installer/configuration.nix`**:
   ```nix
   { pkgs, inputs, ... }:
   {
     imports = [
       inputs.self.modules.bootstrap.bootstrap
       # Add minimal modules needed for installation
     ];

     # Include this repository in the ISO
     environment.systemPackages = with pkgs; [
       git
       vim
       curl
       wget
     ];

     # Pre-clone this repository (optional)
     # Could use systemd.services or environment.etc

     # Set hostname for installer
     networking.hostName = "nixos-installer";

     # Enable flakes
     nix.settings.experimental-features = [ "nix-command" "flakes" ];

     system.stateVersion = "25.05";
   }
   ```

3. **Add output to flake** (may require Blueprint modification or manual addition):
   ```nix
   # This might need to go after Blueprint's outputs
   packages.x86_64-linux.installer-iso = nixos-generators.nixosGenerate {
     system = "x86_64-linux";
     modules = [
       ./hosts/installer/configuration.nix
     ];
     format = "install-iso";
   };
   ```

**Challenge**: Blueprint delegates all output generation, so we may need to work within Blueprint's framework or add custom outputs alongside Blueprint.

#### Option 2: Manual ISO Configuration (Blueprint-Native)

**Advantages**:
- Works within Blueprint's auto-discovery system
- No additional dependencies
- More control over ISO contents

**Required Changes**:

1. **Create `hosts/installer/configuration.nix`**:
   ```nix
   { pkgs, inputs, modulesPath, ... }:
   {
     imports = [
       # Import the base installation ISO configuration
       "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

       # Import your custom modules
       inputs.self.modules.bootstrap.bootstrap
     ];

     # ISO-specific settings
     isoImage.makeEfiBootable = true;
     isoImage.makeUsbBootable = true;

     # Include repository in ISO
     environment.systemPackages = with pkgs; [
       git
       vim
       tmux
       curl
       wget
       nixos-generators  # For disko if needed
     ];

     # Optionally pre-install this repo
     environment.etc."nixos-config".source = inputs.self;

     networking.hostName = "nixos-installer";

     system.stateVersion = "25.05";
   }
   ```

2. **Build command**:
   ```bash
   # Blueprint should auto-discover the installer host
   nix build .#nixosConfigurations.installer.config.system.build.isoImage
   ```

**Challenge**: Need to verify Blueprint correctly exposes ISO build outputs.

### Testing Plan

Once implemented, test the custom ISO:

1. **Build the ISO**:
   ```bash
   nix build .#installer-iso  # or appropriate output name
   ls -lh result/iso/
   ```

2. **Test in a VM**:
   ```bash
   # Quick VM test
   nix-shell -p qemu
   qemu-system-x86_64 \
     -enable-kvm \
     -m 4096 \
     -cdrom result/iso/nixos-*.iso \
     -boot d
   ```

3. **Verify ISO contents**:
   - Repository is accessible
   - Network configuration works
   - Installation commands function correctly

4. **Full installation test**:
   - Write ISO to USB
   - Boot on test hardware
   - Complete full installation
   - Verify system boots correctly

### Recommended Path Forward

1. **Start with Option 2** (Manual ISO Configuration) since it works within Blueprint's framework
2. Create minimal `hosts/installer/configuration.nix` with just essential tools
3. Test build process: `nix build .#nixosConfigurations.installer.config.system.build.isoImage`
4. Iteratively add features (pre-installed repo, additional tools, etc.)
5. Document the build process in this guide once working
6. Consider Option 1 (nixos-generators) later if more flexibility needed

### Additional Considerations

**Size Management**:
- Keep ISO minimal (~1-2GB) for faster downloads
- Include only essential packages
- Use binary caches to speed up installation

**Repository Inclusion**:
- Option A: Pre-clone repository into ISO at `/etc/nixos-config`
- Option B: Include as read-only via `environment.etc`
- Option C: Just ensure git is available and clone during install

**Network Tools**:
- Include both wpa_supplicant and NetworkManager
- Consider including common WiFi firmware
- Test on various hardware configurations

**Documentation Updates**:
- Update this guide with actual build commands once implemented
- Add troubleshooting section for custom ISO issues
- Document any Blueprint-specific considerations

### References

- **nixos-generators**: https://github.com/nix-community/nixos-generators
- **NixOS ISO Documentation**: https://nixos.org/manual/nixos/stable/index.html#sec-building-cd
- **Building Bootable ISO**: https://nix.dev/tutorials/nixos/building-bootable-iso-image.html
- **Blueprint Framework**: https://github.com/numtide/blueprint
