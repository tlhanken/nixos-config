# OpenSpec Specification: Fleet Host Topology & Hardware Specifications

## Intent & Objectives
Define the roles, hardware capabilities, and provisioning standards for each physical and virtual host in the fleet, ensuring appropriate workload allocation and hardware integration without hardcoding transient runtime data.

## Host Intent & Capabilities

### 1. Workstation Host (`sleipnir`)
- **Primary Role**: Interactive developer workstation and mobile laptop.
- **Hardware Integration Intent**:
  - **MUST** configure Intel IOMMU and PCIe tunneling to enable full Thunderbolt 4 / USB4 dock functionality and DisplayPort Alt Mode output.
  - **MUST** provide automated screen orientation and touchscreen coordinate transformation matching physical device rotation via accelerometer sensor events.
  - **MUST** support peripheral firmware management (`fwupd`) and thunderbolt security pairing (`bolt`).

### 2. Media Storage Host (`galar`)
- **Primary Role**: Dedicated local media vault and primary streaming host.
- **Storage Intent**:
  - **MUST** physically host local media dataset (`/mnt/local/media`).
  - **MUST** serve media files to authorized fleet devices over encrypted internal network mounts.
  - **MUST** isolate media storage performance from intensive compute or AI workloads.

### 3. AI Compute & NAS Host (`well-of-mimir-2`)
- **Primary Role**: Central storage NAS and high-performance AI inference server.
- **Storage & Compute Intent**:
  - **MUST** physically host fleet data vaults (`/mnt/local/vault`) and shared AI datasets (`/mnt/local/ai`).
  - **MUST** export shared datasets to authorized client hosts via secure NFS mounts.
  - **MUST** execute resource-heavy web portals, AI pipelines (ComfyUI, Hermes agent), and central infrastructure services.

## Provisioning Standards
- **Declarative Disk Partitioning**: All hosts **MUST** define declarative partition and filesystem layouts using Disko (`disk-config.nix`).
- **Hardware Detection**: Hosts **MUST** utilize `nixos-facter` hardware reports (`facter.json`) for hardware configuration.
- **ZFS Integration**: Hosts requiring ZFS pools **MUST** declare a unique host ID and utilize the custom bootloader module (`bootstrapinstall/bootloader.nix`).
