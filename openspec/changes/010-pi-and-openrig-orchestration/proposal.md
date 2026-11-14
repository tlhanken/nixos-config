# OpenSpec Change Proposal: 010-pi-and-openrig-orchestration

## Summary
Implement a split AI agent architecture across the fleet:
1. **Workstation (`sleipnir`)**: Interactive, low-latency `pi` coding agent CLI in Home Manager (`profile-development.nix`) for local pair-programming, alongside the `openrig` CLI (`rig`) for remote fleet supervision over Tailscale.
2. **Server (`well-of-mimir-2`)**: Persistent `openrig` coordination daemon running 24/7 as a NixOS service (`apps/openrig.nix`), managing autonomous `pi-durable` agent seats in background `tmux` sessions with `gondolin` micro-VM sandboxing and local Forgejo git integration.

## Motivation
1. **Separation of Interactive vs. Autonomous Workloads**: Local development requires instantaneous edits and low latency without remote session lag, while long-running autonomous tasks (bulk refactoring, continuous test loops, PR review swarms) need an always-on host that does not stop when the developer's laptop sleeps or disconnects.
2. **Durable, Crash-Proof Agent State**: Standard agent runs are ephemeral and vanish upon process termination. Running `pi-durable` on the server persists intermediate steps, tool calls, and model context to local SQLite, enabling seamless resumption across reboots.
3. **Hardware Sandboxing via Gondolin**: Unattended agents with terminal access present security risks. Upstream Earendil Works' `gondolin` provides sub-second KVM/QEMU micro-VM sandboxing with virtual filesystem mounts and network egress filtering, isolating autonomous runs from the server host.
4. **Local Git Loop via Forgejo**: Server agents can autonomously branch, test, and submit pull requests directly to the self-hosted Forgejo instance on `well-of-mimir-2`.
5. **Declarative Flake & Ledger Compliance**: Adheres to the repo's Flake-First rule for `pi` (`github:earendil-works/pi/stable`) and Package Ledger requirements for `openrig` (`@openrig/cli`), avoiding untracked hardpins.

## Proposed Changes

### 1. Flake Dependency Tracking (`flake.nix`)
- Add `inputs.pi`:
  ```nix
  pi = {
    url = "github:earendil-works/pi/stable";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  ```

### 2. Package Ledger Integration (`docs/PACKAGE_LEDGER.md`, `nix/packages/openrig.nix`)
- Create `nix/packages/openrig.nix` wrapping `@openrig/cli` from the npm registry with Node 22, `procps` (`ps`), `lsof`, `tmux`, `git`, and `openssh` in runtime `PATH`.
- Create `scripts/update-openrig.sh` to automate npm release inspection and hash generation.
- Add `update-openrig` recipe to `justfile` and chain into `scripts/update-apps.sh`.
- Register `openrig` in `docs/PACKAGE_LEDGER.md`.

### 3. Home Manager Profile (`nix/modules/home/profile-development.nix`)
- Add `inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.default` to `home.packages`.
- Add `openrig` package (`rig`) and `pkgs.tmux` to `home.packages` for local and remote orchestration.

### 4. Server Application Module (`nix/modules/apps/openrig.nix`)
- Create a NixOS service module `services.openrig`:
  - `enable`: Boolean option to activate the daemon.
  - `port`: Web dashboard / RPC control port (default: 3030).
  - `host`: Optional explicit bind host (`null` by default, using OpenRig's loopback `127.0.0.1` + Tailscale multi-bind mode).
  - `webUi`: Boolean option (default: `true`) exported as `OPENRIG_UI_ENABLED` to serve the web UI declaratively on port `3030`.
  - `stateDir`: Dedicated state and workspace directory (`/mnt/local/appdata/openrig`).
  - `environmentFiles`: Ingests `config.age.secrets.ai-api-keys.path`.
  - `systemd.services.openrig`: Systemd unit ordered `after`/`wants` `tailscaled.service`, configured with `KillMode=process` (preventing daemon restarts from killing persistent `tmux` agent sessions), `pi` + `procps` + `lsof` + `tmux` + `git` + `openssh` + `qemu` in `path` (and `pi` in `environment.systemPackages`), and `kvm` group membership (`/dev/kvm`) for Gondolin micro-VM sandboxing.
- Import `inputs.self.modules.apps.openrig` in `nix/hosts/well-of-mimir-2/configuration.nix`.
- Add OpenRig dashboard bookmark to Homepage ([`apps/homepage.nix`](../nix/modules/apps/homepage.nix)).

### 5. Domain Specifications (`openspec/specs/`)
- Update `apps-and-services.md` with the OpenRig daemon contract, state paths, and network topology.
- Update `home-manager-profiles.md` with `pi` and `rig` tool availability in `profile-development`.

## Verification Plan
1. `just check` (`nix flake check`) passes cleanly across all hosts.
2. Build host configurations:
   - `nh os build .#nixosConfigurations.sleipnir`
   - `nh os build .#nixosConfigurations.well-of-mimir-2`
3. Verify `pi --version` and `rig --version` evaluate properly on `sleipnir`.
4. Verify systemd unit definition and KVM group membership on `well-of-mimir-2`.
