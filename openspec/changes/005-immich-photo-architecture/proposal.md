# OpenSpec Change Proposal: 005-immich-photo-architecture

**Status**: `IMPLEMENTED / COMPLETED`

## Summary
Establish the declarative storage layout, multi-user permissions, and migration contracts for **Immich** on host `well-of-mimir-2`, integrating curated photo collections under `/mnt/local/photos/<username>` and live native uploads under `/mnt/local/appdata/immich/library/<storageLabel>`.

## Motivation
1. **Separated Storage Architecture**: Keeps internal application data, thumbnails, and transcoded caches inside `services.immich.mediaLocation = "/mnt/local/appdata/immich"`, while maintaining curated external libraries outside at `/mnt/local/photos/<username>` to comply with Immich's path boundary rules.
2. **Preservation of Curated Folder Hierarchies**: Enables in-place indexing of existing curated event, trip, and edit folders without flattening or altering directory structures on disk.
3. **Native Upload Ingestion Pipeline**: Configures the storage template (`{{y}}/{{MM}}/{{filename}}`) for chronological ingestion of camera RAW files and future mobile uploads with automatic RAW+JPEG stacking.
4. **Declarative NixOS Permissions**: Enforces standard `0775` permissions with `immich:users` ownership via `systemd.tmpfiles.rules`.

## Changes Executed
- **Immich Module (`nix/modules/apps/immich.nix`)**:
  - Configured `mediaLocation = "/mnt/local/appdata/immich"`.
  - Added `extraGroups = [ "users" ]` to `users.users.immich`.
  - Declared tmpfiles rules for `/mnt/local/appdata/immich`, `/mnt/local/photos/tlhanken`, and `/mnt/local/appdata/immich/library`.
- **Mounts Module (`nix/modules/common/mounts.nix`)**:
  - Added `/mnt/well-of-mimir/photos` NFS automount pointing to `${servers.legacy_nas}:/volume1/homes/tlhanken/Photos`.
- **Domain Specification (`openspec/specs/apps-and-services.md`)**:
  - Documented Immich service capability and storage contracts in Section 9.

## Verification & Execution Results
- **Curated Assets**: 4,006 files (19.8 GB) verified bit-for-bit with exact folder trees preserved in `/mnt/local/photos/tlhanken/`.
- **Camera RAW & Video Ingestion**: 14,611 files (74.4 GB / 75 GB on disk) uploaded via `immich-go` into `library/admin/{{y}}/{{MM}}/` with RAW+JPEG pairs stacked cleanly.
- **Flake Evaluation**: `just check` (`nix flake check`) passed 100% cleanly across all fleet targets (`galar`, `sleipnir`, `well-of-mimir-2`).
- **Live Activation**: Deployed and active on host `well-of-mimir-2`.
