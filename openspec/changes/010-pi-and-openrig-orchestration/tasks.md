# Tasks: 010-pi-and-openrig-orchestration

- [x] 1. Flake Dependency Tracking (`flake.nix`) <!-- id: 1 -->
  - [x] 1.1 Declare `inputs.pi` (`github:earendil-works/pi/stable`) with `nixpkgs-unstable` follows <!-- id: 1.1 -->
  - [x] 1.2 Lock `pi` input in `flake.lock` <!-- id: 1.2 -->

- [x] 2. Package Ledger Integration (`docs/PACKAGE_LEDGER.md`, `nix/packages/openrig.nix`) <!-- id: 2 -->
  - [x] 2.1 Create `nix/packages/openrig.nix` derivation wrapping `@openrig/cli` with Node 22, `procps`, `lsof`, `tmux`, `git`, and `openssh` <!-- id: 2.1 -->
  - [x] 2.2 Create automated update script `scripts/update-openrig.sh` <!-- id: 2.2 -->
  - [x] 2.3 Add `update-openrig` (alias: `uorig`) recipe to `justfile` and register in `scripts/update-apps.sh` <!-- id: 2.3 -->
  - [x] 2.4 Register `openrig` in `docs/PACKAGE_LEDGER.md` with upstream tracking details <!-- id: 2.4 -->

- [x] 3. Home Manager Profile (`nix/modules/home/profile-development.nix`) <!-- id: 3 -->
  - [x] 3.1 Expose `inputs.pi.packages.${system}.default` in `home.packages` on `sleipnir` <!-- id: 3.1 -->
  - [x] 3.2 Add `openrig` package and `pkgs.tmux` to `home.packages` for local/remote orchestration <!-- id: 3.2 -->

- [x] 4. Server Application Module (`nix/modules/apps/openrig.nix`) <!-- id: 4 -->
  - [x] 4.1 Define NixOS service module `services.openrig` with `port`, `host` (`null` default for loopback + Tailscale multi-bind), `webUi` (`OPENRIG_UI_ENABLED`), `stateDir`, and secrets options <!-- id: 4.1 -->
  - [x] 4.2 Configure systemd unit `openrig.service` ordered after `tailscaled.service` with `KillMode=process`, `pi`/`procps`/`lsof` in `path` (and `pi` in `systemPackages`), and KVM hardware access <!-- id: 4.2 -->
  - [x] 4.3 Import `inputs.self.modules.apps.openrig` into `nix/hosts/well-of-mimir-2/configuration.nix` <!-- id: 4.3 -->
  - [x] 4.4 Add OpenRig service entry to `apps/homepage.nix` for Tailscale dashboard access <!-- id: 4.4 -->

- [x] 5. Domain Specifications (`openspec/specs/`) <!-- id: 5 -->
  - [x] 5.1 Update `openspec/specs/apps-and-services.md` with OpenRig daemon contracts <!-- id: 5.1 -->
  - [x] 5.2 Update `openspec/specs/home-manager-profiles.md` with Pi and OpenRig tooling in `profile-development` <!-- id: 5.2 -->

- [x] 6. Verification and Flake Check <!-- id: 6 -->
  - [x] 6.1 Run `just check` (`nix flake check`) cleanly <!-- id: 6.1 -->
  - [x] 6.2 Test build evaluation of `sleipnir` and `well-of-mimir-2` <!-- id: 6.2 -->
