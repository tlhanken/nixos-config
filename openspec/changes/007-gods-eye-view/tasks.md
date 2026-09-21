# OpenSpec Tasks: 007-gods-eye-view

- [x] 1. Register `gods-eye-view-secrets.age` in `nix/modules/secrets/secret_files/secrets.nix` and `nix/modules/secrets/mod.nix`.
- [x] 2. Create `nix/modules/apps/gods-eye-view.nix` with pure Nix derivation, hardened systemd service, Nginx reverse proxy, and firewall rules.
- [x] 3. Import `inputs.self.modules.apps.gods-eye-view` in `nix/hosts/well-of-mimir-2/configuration.nix`.
- [x] 4. Register God's Eye View in `nix/modules/apps/homepage.nix` under Tools with `mdi-earth` icon.
- [x] 5. Update `openspec/specs/apps-and-services.md` with God's Eye View capabilities and contracts.
- [x] 6. Run `just check` (`nix flake check`) and build evaluation to verify configuration sanity.
