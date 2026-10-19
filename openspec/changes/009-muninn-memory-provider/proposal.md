# OpenSpec Change Proposal: 009-muninn-memory-provider

## Summary
Integrate **Muninn** (`github:tlhanken/muninn`), a custom QMD/Obsidian-backed memory provider and wiki knowledge engine, into both `profile-hermes.nix` (Home Manager profile on `sleipnir`) and `apps/hermes.nix` (NixOS service module on `well-of-mimir-2`) as the default memory provider for Hermes Agent.

## Motivation
1. **Unified Wiki Memory Architecture**: Muninn bridges Hermes Agent with the QMD search engine, providing OKF-aware search filtering, wikilink extraction, write/append tools (`wiki_search`, `wiki_read`, `wiki_write`, `wiki_append`, `wiki_refresh`), and living knowledge verification.
2. **Elimination of Ad-hoc Symlinks**: Previously, `qmd-wiki` was loaded via a manual symlink in `~/.hermes/plugins/qmd-wiki` pointing to a local repository path. Consuming Muninn as a Flake input (`inputs.muninn`) with entry-point discovery via Python `extraPythonPackages` replaces runtime filesystem links with deterministic, declarative Nix dependencies across hosts.
3. **Declarative Provider Configuration**: Importing `muninn.nixosModules.default` and `muninn.homeManagerModules.default` ensures `settings.memory.provider = "muninn"` is declaratively configured and deep-merged into Hermes's `config.yaml` upon activation.
4. **Tool Exposure**: When `toolsets` are explicitly restricted (as on server host `well-of-mimir-2`), `"memory"` must be included in `settings.toolsets` so that external memory provider tools are permitted and exposed to the model.

## Proposed Changes

### 1. Flake Dependency Tracking (`flake.nix`)
- Declared `inputs.muninn` tracking `github:tlhanken/muninn` with `inputs.hermes-agent.follows = "hermes-agent"` and `inputs.nixpkgs.follows = "nixpkgs-unstable"`, ensuring exact Python interpreter ABI alignment.

### 2. Home Manager Profile (`nix/modules/home/profile-hermes.nix`)
- Import `inputs.hermes-agent.homeManagerModules.default` and `inputs.muninn.homeManagerModules.default`.
- Enable `programs.hermes-agent.enable = true` and `programs.hermes-agent.desktop.enable = true`.
- Enable `services.hermes-agent.enable = true` with `extraDependencyGroups = [ "edge-tts" "voice" "messaging" "web" "firecrawl" ]`.
- Muninn module automatically adds the `muninn` package to `extraPythonPackages` and defaults `settings.memory.provider = "muninn"`.
- Clean up redundant manual package overrides in `home.packages`.

### 3. Server Application Module (`nix/modules/apps/hermes.nix`)
- Import `inputs.muninn.nixosModules.default`.
- Add `"memory"` to `services.hermes-agent.settings.toolsets` alongside `"terminal"`, `"file"`, and `"web"`.
- Set `QMD_WIKI_DIR = "/mnt/local/appdata/hermes/workspace/wiki"` in `services.hermes-agent.environment` and `systemd.services.hermes-dashboard.environment`.
- Update `hermes-dashboard` to run with `hermesPkg` (the effective package containing Muninn in `PYTHONPATH` and the required dependency groups).

### 4. Domain Specifications (`openspec/specs/`)
- Update `apps-and-services.md` and `home-manager-profiles.md` with Muninn memory provider contracts.

## Verification Plan
- Validate flake evaluation across all hosts using `nix flake check`.
- Verify `settings.memory.provider = "muninn"` evaluates cleanly on both `sleipnir` and `well-of-mimir-2`.
- Verify Muninn Python package is in `PYTHONPATH` and `extraPythonPackages` for Hermes Agent and dashboard binaries.
