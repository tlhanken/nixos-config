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

# Update all flake inputs
[group("Flake")]
update:
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

alias rs := rekey-secrets
alias es := edit-secret