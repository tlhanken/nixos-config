# OpenSpec Tasks: 004-forgejo-git-server

- [x] 1. Create `nix/modules/apps/forgejo.nix` with standard Forgejo service configuration, persistent appdata paths, and firewall rules.
- [x] 2. Update `nix/modules/apps/homepage.nix` to include Forgejo in the fleet dashboard under Tools.
- [x] 3. Import `inputs.self.modules.apps.forgejo` into `nix/hosts/well-of-mimir-2/configuration.nix`.
- [x] 4. Update `openspec/specs/apps-and-services.md` with Forgejo service capabilities and contracts.
- [x] 5. Run `just check` (`nix flake check`) and build evaluation to verify configuration sanity.
