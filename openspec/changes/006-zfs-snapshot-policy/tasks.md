# OpenSpec Tasks: 006-zfs-snapshot-policy

- [x] 1. Audit all fleet storage paths and dataset snapshot configurations across `sleipnir`, `galar`, and `well-of-mimir-2`.
- [x] 2. Update `nix/hosts/galar/disk-config.nix` with explicit `com.sun:auto-snapshot` properties for `vault` (`true`), `media` (`false`), and `ai` (`false`).
- [x] 3. Update `nix/hosts/well-of-mimir-2/disk-config.nix` to disable auto-snapshots on `ai` (`false`).
- [x] 4. Update domain specification `openspec/specs/networking-and-storage.md` with ZFS Dataset Snapshot Contracts.
- [x] 5. Imperatively sync live systems (`zfs set com.sun:auto-snapshot=false zroot/ai` on `well-of-mimir-2`) and destroy stale AI model snapshots to reclaim disk space.
- [x] 6. Validate configuration and Disko evaluation across all targets.
