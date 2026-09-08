# OpenSpec Specification: Fleet Networking & Storage Contracts

## Intent & Objectives
Establish centralized network resolution and declarative cross-device dataset sharing, ensuring seamless file access between hosts without hardcoded IP addresses or ad-hoc mount scripts.

## Networking Invariants
- **Single Source of Truth**: All host IP addresses and network topology parameters **MUST** be defined in `nix/lib/network.nix`.
- **No Hardcoded IPs**: Modules and configuration files **MUST NOT** contain hardcoded Tailscale or LAN IP addresses; all references MUST import from `lib/network.nix`.
- **Mesh Transport**: Fleet devices **MUST** interconnect via Tailscale Mesh VPN (`100.64.0.0/10` subnet) under the `fenrir-altered.ts.net` domain.

## Storage & Mount Contract (`my.mounts.*`)

### Option Interface Contract
The `my.mounts` framework provides a unified option schema for cross-host dataset management:
- `enable` (bool): Master toggle to mount the dataset on the local machine.
- `mode` ("local" | "remote"):
  - `"local"`: Designates the host as the physical storage owner.
  - `"remote"`: Mounts the dataset from the physical owner via NFS over Tailscale.
- `localPath` (string): Absolute local directory path when `mode = "local"`.
- `writable` (bool): Determines if remote NFS clients receive read-write or read-only access (default: read-only).
- `exportNfs` (bool): Toggles NFS server export rules for the dataset on the host owner.

### Standard Datasets & Ownership Invariants
1. **Media Dataset (`my.mounts.media`)**:
   - Physical Owner: `galar` (`/mnt/local/media`).
   - Consumer Hosts: `sleipnir`, `well-of-mimir-2`.
2. **Vault Dataset (`my.mounts.vault`)**:
   - Physical Owner: `well-of-mimir-2` (`/mnt/local/vault`).
   - Consumer Hosts: `sleipnir`, `galar`.
3. **AI Dataset (`my.mounts.ai`)**:
   - Physical Owner: `well-of-mimir-2` (`/mnt/local/ai`).
   - Purpose: Stores shared model weights and training datasets.
4. **Hermes Workspace (`my.mounts.hermes`)**:
   - Physical Owner: `well-of-mimir-2` (`/mnt/local/appdata/hermes`).
   - Consumer Host: `sleipnir` (exported via NFS for live remote editing).

### NFS Security & Access Rules
- NFS exports **MUST** restrict client access strictly to designated Tailscale IPs specified in `lib/network.nix`.
- Mount operations **MUST NOT** block system boot if a remote storage server is temporarily unreachable.

## ZFS Dataset Snapshot Contracts

Fleet hosts running ZFS enable automated snapshots via `services.zfs.autoSnapshot` in `nixos/host-shared.nix`. To avoid disk exhaustion from high-churn binary files while guaranteeing point-in-time recovery for critical state, datasets **MUST** adhere to the following snapshot policies:

### 1. Opt-Out Datasets (`com.sun:auto-snapshot = false`)
- **Deterministic Stores (`/nix`)**: Nix derivations are reproducible from source flakes. Auto-snapshots **MUST NOT** be enabled to prevent defeating `nix-collect-garbage`.
- **Media Libraries (`my.mounts.media` on `galar`)**: Bulk video and music assets **MUST NOT** be automatically snapshotted to avoid churn and lockup of storage during high-volume downloads or transcoding.
- **AI Model Weights (`my.mounts.ai` on `well-of-mimir-2`)**: Multi-gigabyte LLM and diffusion model weights **MUST NOT** be automatically snapshotted so deleted models can immediately reclaim NVMe disk space.

### 2. Opt-In & Inherited Datasets (`com.sun:auto-snapshot = true`)
- **System Configuration (`/`)**: Root filesystem snapshots provide fast rollback against failed updates or breaking system changes.
- **User Home Directories (`/home`)**: User dotfiles, desktop configurations, and local files **MUST** maintain active auto-snapshots.
- **Vault Data (`my.mounts.vault` on `galar` and `well-of-mimir-2`)**: Persistent documents, long-term archives, and personal files **MUST** maintain active auto-snapshots.
- **Application State (`/mnt/local/appdata/*` on `well-of-mimir-2`)**: Databases, personal photo uploads (Immich), git repositories (Forgejo), agent memories (Hermes), and password stores (Vaultwarden) **MUST** maintain active automated snapshots.

