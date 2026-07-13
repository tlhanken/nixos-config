# nixos-config

NixOS configuration for home devices, built on the [Blueprint](https://github.com/numtide/blueprint) framework.

## Hosts

| Host | Role | Hardware |
|------|------|----------|
| `sleipnir` | Primary workstation / daily driver | Framework Laptop 12 (Intel) |
| `galar` | Home server — media, NFS, Jellyfin | Custom build |

## Quick Start

All common tasks are wrapped in `just`. Run `just` with no args to list everything.

```bash
just build          # Build current host
just test           # Test (volatile — no persistence)
just switch         # Switch and activate
just check          # Validate the flake

just remote-switch <host>              # Deploy remotely via Tailscale
just install <ip> <config> <host>      # Fresh install via nixos-anywhere

just edit-secret <name>   # Edit an agenix encrypted secret (alias: es)
just rekey-secrets        # Rekey all secrets after key changes (alias: rs)
```

## Deployment

See [docs/deployment.md](docs/deployment.md) for full instructions on installing NixOS on a new machine using a Linux Mint Live USB.

### Fresh Installation (Quick Method)

If you are using the standard **NixOS Minimal ISO**, the deployment process is extremely simple:

1. Boot the target machine using the NixOS Minimal ISO.
2. When the terminal appears, start SSH and set a temporary root password:
   ```bash
   sudo systemctl start sshd
   sudo passwd root
   ```
3. Type `ip a` to get the machine's IP address.
4. From your development machine inside this repo, run:
   ```bash
   just install <IP_ADDRESS> <CONFIG_NAME> <HOST_NAME>
   ```
   *(Example: `just install 192.168.1.50 well-of-mimir well-of-mimir`)*

The script will automatically SSH in, wipe the disks, format everything, generate the hardware configuration (`facter.json`), and install the OS.

## Setup (First Time)

1. **GitHub** — fork/clone this repo
2. **Garnix** — link your GitHub account at [garnix.io](https://garnix.io) and connect the repo for CI builds
3. **Garnix GitHub App** — install the app, grant repo access, and add any required secrets to the repo's GitHub settings

## Structure

All Nix configuration lives under `nix/` (Blueprint `prefix`):

```
nix/
├── hosts/
│   ├── sleipnir/   # Framework 12 workstation
│   └── galar/      # Home server
└── modules/
    ├── bootstrap/        # Install-time essentials only (curl, git, flakes)
    ├── bootstrapinstall/ # Boot overrides, locale, Tailscale, secrets
    ├── common/           # Shared services, mounts
    ├── desktop/          # Cinnamon or GNOME + X11 (see `my.desktop.session`)
    ├── nixos/            # Shared host baseline (Nix, SSH, GRUB/ZFS)
    ├── apps/             # System level applications (servers, etc.)
    ├── home/             # Home-manager + user profiles
    └── secrets/          # agenix encrypted secrets
```

See [CLAUDE.md](CLAUDE.md) for full architecture details and development guidance.

## Backlog

See [docs/TODO.md](docs/TODO.md) for security, AI apps, and packaging follow-ups.

Other ideas:

- **Disk encryption (LUKS)** — especially for sleipnir (laptop)
- **`well-of-mimir` NixOS config** — machine exists but isn't managed by this flake yet
- **Nextcloud** — self-hosted file sync / productivity suite
- **Restic backups** — automated encrypted backups with a restic server or remote target
