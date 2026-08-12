# OpenSpec Tasks: 003-hermes-edgetts-workspace-hardening

- [x] 1. Update `nix/modules/apps/hermes.nix` with Edge-TTS provider settings (`voice = "en-US-AvaNeural"`), expanded `extraPackages`, and workspace directory structure (`wiki`, `repos`, `tmp`, `shared`).
- [x] 2. Add systemd `hermes-repos-init` service to pre-clone `nixos-config`, `tools`, and `geoforge` into `workspace/repos/`.
- [x] 3. Run `nix flake check` and `nix build .#nixosConfigurations.well-of-mimir-2.config.system.build.toplevel` for verification.
