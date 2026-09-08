# OpenSpec Tasks: 005-immich-photo-architecture

- [x] 1. Configure `nix/modules/apps/immich.nix` with separated storage boundaries (`mediaLocation = "/mnt/local/appdata/immich"`), multi-user permissions (`users` group), and declarative tmpfiles rules.
- [x] 2. Configure legacy photo library NFS mount in `nix/modules/common/mounts.nix` under `/mnt/well-of-mimir/photos`.
- [x] 3. Import `inputs.self.modules.apps.immich` into `nix/hosts/well-of-mimir-2/configuration.nix` and register on Fleet Dashboard (`homepage.nix`).
- [x] 4. Migrate curated photo collections into `/mnt/local/photos/tlhanken` preserving directory trees bit-for-bit (4,006 assets, 19.8 GB).
- [x] 5. Ingest camera RAW files and videos via `immich-go` into `library/admin/{{y}}/{{MM}}/` with automatic RAW+JPEG stacking (14,611 assets, 74.4 GB).
- [x] 6. Document Immich service capabilities and storage contracts in `openspec/specs/apps-and-services.md`.
- [x] 7. Validate configuration sanity with `just check` (`nix flake check`) and deploy to `well-of-mimir-2`.
