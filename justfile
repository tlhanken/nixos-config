_default:
    @just --list

# Remove build results and temporary files
[confirm("Are you sure you want to delete all result folders?")]
[group("Utility")]
clean:
    @echo "Cleaning up..."
    @rm -rf result
    @rm -rf result-*

# Run checks on the flake (including evaluation and tests)
[group("Flake")]
check:
    nix flake check

# Show the structure and contents of the flake
[group("Flake")]
show:
    nix flake show

# Display flake metadata and input dependencies
[group("Flake")]
metadata:
    nix flake metadata

# Update all flake inputs and out-of-flake applications
[group("Flake")]
update: update-flake update-apps

# Update only flake inputs in flake.lock
[group("Flake")]
update-flake:
    nix flake update

# Build the specified configuration (defaults to '.')
[group("System")]
build path=".":
    nh os build {{path}}

# Test the specified configuration in a volatile fashion (defaults to '.')
[group("System")]
test target=".":
    nh os test {{target}}

# Switch to the specified configuration (defaults to '.')
[group("System")]
switch target=".":
    nh os switch {{target}}

# Switch a remote host configuration via Tailscale
[group("System")]
remote-switch host:
    nixos-rebuild switch --flake .#{{host}} --target-host root@{{host}}.fenrir-altered.ts.net

# Test a remote host configuration via Tailscale (volatile, reboot reverts to previous generation)
[group("System")]
remote-test host:
    nixos-rebuild test --flake .#{{host}} --target-host root@{{host}}.fenrir-altered.ts.net

# Install NixOS onto a new host using nixos-anywhere
[group("System")]
install ip config host:
    nixos-anywhere root@{{ip}} -f .#{{config}} --generate-hardware-config nixos-facter ./nix/hosts/{{host}}/facter.json

# Rekey all encrypted secrets
[working-directory: 'nix/modules/secrets/secret_files']
[group("Secrets")]
rekey-secrets:
    @echo "Rekeying secrets..."
    @agenix -r -i ~/.ssh/id_ed25519

# Edit an encrypted secret file
[working-directory: 'nix/modules/secrets/secret_files']
[group("Secrets")]
edit-secret SECRET:
    @agenix -e encrypted/{{SECRET}}.age

# Update all out-of-flake custom applications and packages
[group("Apps")]
update-apps:
    @./scripts/update-apps.sh

# Update God's Eye View to latest upstream commit and refresh npm hashes
[group("Apps")]
update-gods-eye-view:
    @./scripts/update-gods-eye-view.sh

# Update Hermes-Mod to latest npm version and refresh npm hashes
[group("Apps")]
update-hermes-mod:
    @./scripts/update-hermes-mod.sh

alias rs := rekey-secrets
alias es := edit-secret
alias ugev := update-gods-eye-view
alias uf := update-flake
alias ua := update-apps