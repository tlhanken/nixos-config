# OpenSpec Specification: Home Manager & User Profiles

## Intent & Objectives
Define user environment standards, profile composition rules, and developer toolchain requirements to guarantee reproducible user environments across workstation and server targets.

## Profile Composition Rules
- **Base Environment**: All user configurations **MUST** import `home-shared.nix` for shell baseline settings, version control tools, and prompt defaults.
- **Role Isolation**: Tool sets **MUST** be split into focused profiles (`profile-development`, `profile-productivity`, `profile-art`, `profile-hermes`) rather than bundled into a monolithic configuration.

## Profile Requirements & Contracts

### 1. Shared Baseline (`home-shared.nix`)
- **MUST** configure Git defaults, `direnv` integration with `nix-direnv`, and Starship shell prompt across all hosts.

### 2. Development Profile (`profile-development.nix`)
- **Capability**: Comprehensive multi-language development environment.
- **Contract**:
  - **MUST** provide core runtimes (Node.js, Python 3, `uv`).
  - **MUST** include OpenSpec CLI (`openspec`) for AI agent workflow management.
  - **MUST** configure Jujutsu (`jj`) VCS aliases and VS Code extensions for Nix, Rust, and Python.
  - **MUST** provide AI coding tools (Claude Code, Gemini CLI, Cursor FHS, Antigravity IDE FHS).

### 3. Agent Integration Profile (`profile-hermes.nix`)
- **Capability**: Desktop launcher, native Electron GUI application, and runtime environment for the Hermes AI workspace agent.
- **Contract**:
  - **MUST** include the native `hermes-desktop` Electron application package (`inputs.hermes-agent.packages.${system}.desktop`).
  - **MUST** provide desktop launchers and configuration state without interfering with standard user home directory files.

### 4. Custom Package Maintenance
- Custom packages (`openspec.nix`, `hermes-mod.nix`) **MUST** use explicit dependency locking (e.g. `package-lock.json` injection) to ensure deterministic builds.
