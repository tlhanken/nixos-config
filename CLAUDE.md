# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS configuration repository for multiple home devices using the **Blueprint** framework from numtide. Blueprint provides a flake-based architecture that auto-discovers hosts and modules from directory structure.

## Common Commands

### Testing and Building
```bash
# Check flake for errors and run tests
nix flake check

# Show all packages and outputs
nix flake show

# Test configuration for current host, deploying to current host temporarily
nh os test .

# Test specific host configuration
nh os test .#nixosConfigurations.sleipnir

# Apply configuration to current host
nh os switch .

# Apply specific configuration to current host
nh os switch .#nixosConfigurations.sleipnir
```

### Flake Management
```bash
# View flake inputs and check for dependency alignment
nix flake metadata

# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

### Development
```bash
# Enter dev shell (direnv should auto-load)
nix develop

# Generate hardware configuration for new host
nixos-generate-config --show-hardware-config
```

## Architecture

### Blueprint Framework

The flake.nix delegates all configuration to Blueprint:
```nix
outputs = inputs: inputs.blueprint { inherit inputs; };
```

Blueprint **auto-discovers** hosts and modules from directory structure, eliminating manual flake registration. Modules are exposed as `inputs.self.modules.<category>.<name>` and home-manager configs as `inputs.self.homeModules.<name>`.

### Directory Structure

```
├── flake.nix                    # Minimal flake delegating to Blueprint
├── hosts/                       # Per-machine configurations
│   ├── sleipnir/               # Currently active host
│   │   ├── configuration.nix   # Host-specific settings
│   │   ├── hardware-configuration.nix
│   │   └── users/              # Per-user home-manager configs
│   ├── gungnir/                # Additional hosts (not yet configured)
│   ├── galar/
│   └── well-of-mimir/
└── modules/                    # Reusable system modules
    ├── bootstrap/              # Base system setup
    ├── bootstrapinstall/       # Bootloader, locale, ZFS options
    ├── common/                 # Docker, auto-upgrade, ZFS services
    ├── desktop/                # Cinnamon, X11, networking, sound
    ├── apps/                   # Optional apps (Steam, Jellyfin, Ollama)
    └── home/                   # Home-manager shared configs
```

### Module Import Pattern

Hosts import modules using Blueprint's auto-generated namespaces:

```nix
imports = [
  inputs.self.modules.bootstrap.bootstrap
  inputs.self.modules.desktop.desktop
  inputs.self.modules.common.common
  ./hardware-configuration.nix
];
```

User configurations import home-manager modules:
```nix
imports = [ inputs.self.homeModules.home-shared ];
```

### Adding New Hosts

1. Create `/hosts/<hostname>/configuration.nix` with basic config:
   - Set `networking.hostName` and `networking.hostId`
   - Define users and their groups
   - Import desired modules via `inputs.self.modules.*`
2. Generate hardware config: `nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix`
3. Create user configs in `hosts/<hostname>/users/` if using home-manager
4. Blueprint auto-discovers the new host - no flake.nix changes needed
5. Test with: `nh os test .#nixosConfigurations.<hostname>`

### Creating New Modules

1. Create module file in appropriate `modules/<category>/` directory
2. Use standard NixOS module structure with `{ pkgs, ... }: { ... }`
3. Import in host config via `inputs.self.modules.<category>.<filename-without-.nix>`
4. For custom options, use `options` and `config` pattern (see `bootstrapinstall/bootloader.nix` for example)

## Configuration Details

### Nix Settings

- Flakes and nix-command enabled by default
- Binary caches: nix-community.cachix.org and cache.garnix.io
- Auto-optimise store enabled
- `nh` (NixOS Helper) configured with 7-day cleanup keeping last 5 generations

### System Features

- **ZFS**: Configured with custom `customBoot.enable` option for ZFS root support
- **Home-manager**: Integrated for per-user package management and dotfiles
- **Desktop**: Cinnamon desktop environment with X11
- **Auto-updates**: System auto-upgrade enabled (check modules/common/common.nix)
- **Development tools**: Git, direnv, starship prompt via home-manager

### Password Management

User passwords are stored as hashed strings. Generate a has from a password with:
```bash
mkpasswd -m sha-512
```

### Host ID Generation

Required for ZFS. Generate with:
```bash
head -c 8 /etc/machine-id
```
