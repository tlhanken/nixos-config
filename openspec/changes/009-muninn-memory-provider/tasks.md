# Tasks: 009-muninn-memory-provider

- [x] 1. Flake Dependency Integration (`flake.nix`) <!-- id: 1 -->
  - [x] 1.1 Declare `inputs.muninn` with `hermes-agent` and `nixpkgs` follows <!-- id: 1.1 -->
  - [x] 1.2 Lock `muninn` input in `flake.lock` <!-- id: 1.2 -->

- [x] 2. Home Manager Hermes Profile (`nix/modules/home/profile-hermes.nix`) <!-- id: 2 -->
  - [x] 2.1 Import `inputs.hermes-agent.homeManagerModules.default` and `inputs.muninn.homeManagerModules.default` <!-- id: 2.1 -->
  - [x] 2.2 Configure `programs.hermes-agent` (CLI and desktop application) <!-- id: 2.2 -->
  - [x] 2.3 Configure `services.hermes-agent` with `extraDependencyGroups` for declarative configuration <!-- id: 2.3 -->
  - [x] 2.4 Set `hermesDesktopItem` exec path to `config.programs.hermes-agent.package` <!-- id: 2.4 -->
  - [x] 2.5 Clean up redundant manual overrides and package declarations <!-- id: 2.5 -->

- [x] 3. Server Hermes Application Module (`nix/modules/apps/hermes.nix`) <!-- id: 3 -->
  - [x] 3.1 Import `inputs.muninn.nixosModules.default` <!-- id: 3.1 -->
  - [x] 3.2 Add `"memory"` to `services.hermes-agent.settings.toolsets` <!-- id: 3.2 -->
  - [x] 3.3 Set `QMD_WIKI_DIR` in service and dashboard environment <!-- id: 3.3 -->
  - [x] 3.4 Update `hermes-dashboard` to run with `hermesPkg` containing Muninn <!-- id: 3.4 -->

- [x] 4. Domain Specifications (`openspec/specs/`) <!-- id: 4 -->
  - [x] 4.1 Update `apps-and-services.md` with Muninn memory provider contract <!-- id: 4.1 -->
  - [x] 4.2 Update `home-manager-profiles.md` with Muninn profile integration <!-- id: 4.2 -->

- [x] 5. Validation and Flake Check <!-- id: 5 -->
  - [x] 5.1 Run `nix flake check` cleanly <!-- id: 5.1 -->
