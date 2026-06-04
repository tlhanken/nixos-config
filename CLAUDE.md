# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS configuration repository for multiple home devices using the **Blueprint** framework from numtide. Blueprint provides a flake-based architecture that auto-discovers hosts and modules from directory structure. All Nix configuration lives under the `nix/` directory (set via `prefix = "nix/"` in `flake.nix`).

## Common Commands

### Just (Preferred)

A `justfile` at the repo root wraps all common workflows. Run `just` (no args) to list available recipes.

```bash
just check          # Run nix flake check
just show           # Run nix flake show
just metadata       # Display flake metadata

just build          # Build current host config
just test           # Test current host (volatile, no persistence)
just switch         # Switch current host to new config

just remote-switch <host>             # Deploy to remote host via Tailscale
just install <ip> <config> <host>     # Install NixOS on new host with nixos-anywhere

just rekey-secrets  # Rekey all agenix secrets (alias: rs)
just edit-secret <SECRET>  # Edit a specific secret file (alias: es)
```

### Manual Commands

```bash
# Build/test/switch specific host
nh os build .#nixosConfigurations.galar
nh os test  .#nixosConfigurations.sleipnir
nh os switch .#nixosConfigurations.sleipnir

# Deploy remotely (nixos-rebuild)
nixos-rebuild switch --flake .#<host> --target-host root@<host>.fenrir-altered.ts.net

# Install NixOS on new machine
nixos-anywhere root@<ip> -f .#<config> --generate-hardware-config nixos-facter ./nix/hosts/<host>/facter.json
```

### Flake Management

```bash
nix flake update                        # Update all inputs
nix flake lock --update-input nixpkgs  # Update a specific input
```

### Development

```bash
nix develop   # Enter dev shell (direnv auto-loads via .envrc)
```

## Architecture

### Blueprint Framework

The `flake.nix` delegates all configuration to Blueprint with a `nix/` prefix:

```nix
outputs = inputs:
  inputs.blueprint {
    inherit inputs;
    prefix = "nix/";
    systems = ["x86_64-linux"];
  };
```

Blueprint **auto-discovers** hosts and modules from the `nix/hosts/` and `nix/modules/` directories. Modules are exposed as `inputs.self.modules.<category>.<name>` and home-manager configs as `inputs.self.homeModules.<name>`.

### Directory Structure

```
├── flake.nix                       # Minimal flake delegating to Blueprint
├── justfile                        # Common task recipes
├── garnix.yaml                     # Garnix CI configuration
├── docs/                           # Documentation
└── nix/
    ├── devshell.nix / devshells/   # Dev shell definitions
    ├── formatter.nix               # Code formatter config
    ├── guides/                     # Setup and migration guides
    ├── lib/                        # Shared Nix library helpers
    ├── local/                      # Local-only (gitignored) overrides
    ├── hosts/                      # Per-machine configurations
    │   ├── sleipnir/               # Primary workstation
    │   │   ├── configuration.nix
    │   │   ├── disk-config.nix     # Disko disk layout
    │   │   ├── facter.json         # nixos-facter hardware report
    │   │   └── users/              # Per-user home-manager configs
    │   └── galar/                  # Media/server host
    │       ├── configuration.nix
    │       ├── disk-config.nix
    │       ├── facter.json
    │       └── users/
    └── modules/                    # Reusable NixOS/HM modules
        ├── apps/                   # Optional apps (Jellyfin, Minecraft, Ollama, Rust, Steam)
        ├── bootstrap/              # Base system setup
        ├── bootstrapinstall/       # Bootloader, locale, tailscale, ZFS options
        ├── common/                 # Shared system config + mounts + utilities
        ├── desktop/                # Cinnamon, X11, networking, sound
        ├── home/                   # Home-manager modules and user profiles
        ├── nixos/                  # Shared NixOS host config (host-shared.nix)
        └── secrets/                # agenix secret definitions and encrypted files
```

### Module Import Pattern

Hosts import modules using Blueprint's auto-generated namespaces:

```nix
imports = [
  inputs.self.modules.bootstrap.bootstrap
  inputs.self.modules.bootstrapinstall.install
  inputs.self.modules.desktop.desktop
  inputs.self.modules.common.common
  inputs.self.modules.nixos.host-shared
  ./hardware-configuration.nix
];
```

User configurations import home-manager modules:

```nix
imports = [
  inputs.self.homeModules.home-shared
  inputs.self.homeModules.profile-development
];
```

### Key Module Details

| Module | Path | Purpose |
|--------|------|---------|
| `bootstrap` | `modules/bootstrap/` | Base system, Nix settings, binary caches |
| `bootstrapinstall` | `modules/bootstrapinstall/` | ZFS boot, locale, tailscale, bootloader |
| `common` | `modules/common/` | Docker, auto-upgrade, mounts, ZFS services |
| `common/mounts` | `modules/common/mounts.nix` | Cross-host NFS and bind mount configuration |
| `desktop` | `modules/desktop/` | Cinnamon, X11, sound |
| `nixos/host-shared` | `modules/nixos/host-shared.nix` | Shared baseline for all NixOS hosts |
| `apps/*` | `modules/apps/` | Optional per-host applications |
| `home/home-shared` | `modules/home/home-shared.nix` | Shared HM baseline (git, direnv, starship) |
| `home/profile-*` | `modules/home/` | User profiles: art, development, productivity |
| `secrets` | `modules/secrets/` | agenix secret files and key definitions |

### Secrets Management (agenix)

Secrets are encrypted with agenix and stored in `nix/modules/secrets/secret_files/encrypted/`. Keys are defined in `nix/modules/secrets/keys.nix`.

```bash
# Edit a secret
just edit-secret <name>   # e.g. just edit-secret tailscale-key

# After adding/changing keys, rekey all secrets
just rekey-secrets
```

### Adding New Hosts

1. Create `nix/hosts/<hostname>/configuration.nix`:
   - Set `networking.hostName` and `networking.hostId`
   - Import desired modules via `inputs.self.modules.*`
2. Generate hardware report: `nixos-anywhere ... --generate-hardware-config nixos-facter ./nix/hosts/<hostname>/facter.json`
3. Create disk layout: `nix/hosts/<hostname>/disk-config.nix` (Disko)
4. Create user configs in `nix/hosts/<hostname>/users/` if using home-manager
5. Blueprint auto-discovers the new host — no `flake.nix` changes needed
6. Install: `just install <ip> <config> <hostname>`
7. Test: `just test .#nixosConfigurations.<hostname>`

### Creating New Modules

1. Create module file in appropriate `nix/modules/<category>/` directory
2. Use standard NixOS module structure: `{ pkgs, lib, config, ... }: { ... }`
3. Import in host config via `inputs.self.modules.<category>.<filename-without-.nix>`
4. For custom options, use `options` + `config` pattern (see `bootstrapinstall/bootloader.nix`)

### Documentation and Guides

All setup guides, migration guides, and other documentation go in `nix/guides/`.

**AI-Generated Content**: All AI-generated guides MUST include the following disclaimer at the very top:

```markdown
> **⚠️ AI-Generated Content Disclaimer**
>
> This guide was generated with the assistance of artificial intelligence. While efforts have been made to ensure accuracy, please review all commands and configurations carefully before applying them to your system. Always maintain proper backups and verify information against official documentation.
```

## Configuration Details

### Nix Settings

- Flakes and nix-command enabled by default
- Binary caches: `nix-community.cachix.org`, `cache.garnix.io`
- Auto-optimise store enabled
- `nh` (NixOS Helper) configured with 7-day cleanup keeping last 5 generations
- Nixpkgs channel: `nixos-25.11` (stable), with `nixos-unstable` available as overlay source

### System Features

- **ZFS**: Configured with custom `customBoot.enable` option for ZFS root support
- **Disko**: Declarative disk partitioning used for all hosts
- **nixos-facter**: Hardware detection via `facter.json` (replaces `hardware-configuration.nix`)
- **Home-manager**: Integrated for per-user package management and dotfiles, with profile system
- **Desktop**: Cinnamon desktop environment with X11 (sleipnir only)
- **Tailscale**: Configured via `bootstrapinstall/tailscale.nix`, used for remote access
- **Auto-updates**: System auto-upgrade enabled (see `modules/common/`)
- **Development tools**: Git, direnv, starship prompt via home-manager (`profile-development`)
- **Secrets**: agenix for encrypted secrets at rest

### Password Management

User passwords are stored as hashed strings. Generate a hash from a password with:

```bash
mkpasswd -m sha-512
```

### Host ID Generation

Required for ZFS. Generate with:

```bash
head -c 8 /etc/machine-id
```
