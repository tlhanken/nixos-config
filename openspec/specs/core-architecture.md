# OpenSpec Specification: Core Architecture & Blueprint Framework

## Intent & Objectives
Establish a modular, declarative NixOS fleet configuration that auto-discovers hosts and modules, maintains clean isolation between system components, and ensures consistent evaluation and development workflows across all devices.

## Architectural Contracts

### 1. Framework & Directory Invariants
- **MUST** utilize the Blueprint framework for auto-discovering hosts and modules under the `nix/` directory (`prefix = "nix/"` in `flake.nix`).
- **MUST** expose NixOS modules under the `inputs.self.modules.<category>.<name>` namespace.
- **MUST** expose Home Manager modules under the `inputs.self.homeModules.<name>` namespace.
- **MUST NOT** use direct relative imports across distinct module categories; all cross-module imports MUST reference Blueprint auto-discovered inputs (`inputs.self.*`).

### 2. Flake & Target Alignment
- **MUST** target `x86_64-linux` as the primary fleet system platform.
- **MUST** pin system configurations to the stable release channel (`nixos-25.11`), allowing specific unstable overlays (`nixos-unstable`) only for fast-evolving developer tools and AI applications.

### 3. Verification & Task Runner Contracts
- **MUST** ensure all flake changes evaluate cleanly under `nix flake check` (`just check`).
- **MUST** maintain common deployment, build, and rekeying actions within the root `justfile`.
- **MUST** configure system generation cleanup via NixOS Helper (`nh`) to prevent store bloat while preserving rollback safety (minimum 7-day retention).

### 4. Agent Execution Standard
- All AI coding agents (Antigravity, Hermes, Claude Code) **MUST** use OpenSpec (`openspec/specs/` and `openspec/changes/`) for change planning, specification verification, and task execution.

### 5. Dependency Management & Package Ledger Contracts
- **Flake-First Invariant**: All dependencies with Git repositories or Nix Flake interfaces **MUST** be defined in `flake.nix` with appropriate `inputs.<name>.follows`.
- **Zero Silent Pins**: No custom package, fetcher, or derivation with fixed cryptographic hashes (`rev`, `hash`, `npmDepsHash`) may exist without registration in the central Package Ledger (`docs/PACKAGE_LEDGER.md`).
- **Mandatory Automated Updaters**: Every ledger-registered package **MUST** provide an automated update script (`scripts/update-<name>.sh`) and an associated `justfile` recipe.
- **Update Workflow**: The root task runner `just update` **MUST** update all flake inputs (`flake.lock`) and execute the automated updaters for all ledger-registered packages (`just update-apps`).
