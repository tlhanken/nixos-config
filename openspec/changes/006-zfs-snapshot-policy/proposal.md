# OpenSpec Change Proposal: 006-zfs-snapshot-policy

**Status**: `IMPLEMENTED / COMPLETED`

## Summary
Establish explicit ZFS dataset auto-snapshot contracts and tune snapshot flags across fleet hosts (`galar`, `well-of-mimir-2`), disabling automated snapshots on high-churn binary assets (`/mnt/ai`, `/mnt/media`, `/nix`) to prevent disk exhaustion, while guaranteeing point-in-time recovery for persistent document vaults (`/mnt/vault`) and application databases (`/mnt/local/appdata/*`).

## Motivation
1. **Prevent Storage Bloat on AI Inference Servers**: LLM model weights (GGUF) and diffusion checkpoints are massive, immutable binaries (4GB–70GB+ each). Enabling automated snapshots on `/mnt/local/ai` caused deleted models to remain permanently locked across ~40 snapshots, preventing disk space reclamation on NVMe pools.
2. **Prevent Churn on Media Libraries**: Streaming media libraries (`/mnt/local/media`) on `galar` contain multi-terabyte files subject to frequent torrent unpacking, renaming, and transcoding. High-frequency auto-snapshots create excessive I/O and snapshot churn without meaningful recovery benefit.
3. **Guarantee Snapshot Recovery for Document Vaults**: Persistent documents on `galar` (`zvault/vault`) previously defaulted to `false` due to root pool inheritance. Explicitly setting `com.sun:auto-snapshot = true` ensures snapshot protection for personal documents.

## Changes Executed
- **Galar Disko Configuration (`nix/hosts/galar/disk-config.nix`)**:
  - Explicitly set `options."com.sun:auto-snapshot" = "true"` on `vault`.
  - Explicitly set `options."com.sun:auto-snapshot" = "false"` on `media`.
  - Explicitly set `options."com.sun:auto-snapshot" = "false"` on `ai`.
- **Well-of-Mimir-2 Disko Configuration (`nix/hosts/well-of-mimir-2/disk-config.nix`)**:
  - Explicitly set `options."com.sun:auto-snapshot" = "false"` on `ai`.
- **Fleet Networking & Storage Specification (`openspec/specs/networking-and-storage.md`)**:
  - Added Section: `ZFS Dataset Snapshot Contracts` codifying opt-out datasets (`/nix`, `media`, `ai`) and opt-in datasets (`/`, `/home`, `vault`, `appdata/*`).
- **Live System Reconciliations**:
  - Set `com.sun:auto-snapshot = false` on live `zroot/ai` and destroyed 40+ obsolete model snapshots on `well-of-mimir-2`.
  - Verified `zvault/media` on `galar` has 0 active snapshots and confirmed systemd snapshot timers.
