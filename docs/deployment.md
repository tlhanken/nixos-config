# NixOS Deployment Guide

This guide describes how to deploy NixOS to a new machine (or reinstall an existing one) using a **Linux Mint Live USB**. This method is preferred over the minimal NixOS installer because it provides a reliable SSH environment and GUI network tools out of the box.

## Prerequisites

1.  **Linux Mint Live USB**: Download the [Linux Mint Cinnamon Edition](https://linuxmint.com/download.php) ISO and write it to a USB drive.
    *   *Command to write ISO (be careful!):* `sudo dd bs=4M if=linuxmint.iso of=/dev/sdX status=progress oflag=sync`
2.  **Target Machine**: The machine you want to install NixOS on (e.g., `galar`).
3.  **Host Machine**: The machine with this repository (e.g., `sleipnir`).

## Step 1: Prepare Secrets (Host Machine)

If this is a **new** machine or you lost the old keys, you must generate a new SSH host key and rekey the secrets.

1.  Generate a temporary key for the new host:
    ```bash
    mkdir -p temp_keys
    ssh-keygen -t ed25519 -f temp_keys/ssh_host_ed25519_key -N "" -C "root@hostname"
    ```

2.  Get the public key:
    ```bash
    cat temp_keys/ssh_host_ed25519_key.pub
    ```

3.  Add this public key to `nix/modules/secrets/secret_files/secrets.nix`.

4.  Rekey the secrets:
    ```bash
    cd nix/modules/secrets/secret_files
    nix run github:ryantm/agenix -- -r
    ```

5.  Prepare the `extra-files` directory to upload the key during install:
    ```bash
    # From the repo root
    mkdir -p extra-files/etc/ssh
    cp temp_keys/ssh_host_ed25519_key extra-files/etc/ssh/
    chmod 600 extra-files/etc/ssh/ssh_host_ed25519_key
    ```

## Step 2: Prepare Target (Target Machine)

1.  **Boot Linux Mint** on the target machine.
2.  **Connect to WiFi/Ethernet** using the GUI.
3.  Open a terminal and set up the environment:
    ```bash
    # 1. Install SSH Server
    sudo apt update && sudo apt install openssh-server -y

    # 2. Set a password for the 'mint' user
    sudo passwd mint
    # (Choosing a simple password like 'mint' is fine for this temporary session)

    # 3. Get the IP address
    ip a
    ```

## Step 3: Deploy (Host Machine)

Run the `nixos-anywhere` command from this repository.

*   Replace `galar` with the hostname defined in `flake.nix`.
*   Replace `192.168.x.x` with the IP address of the target.

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#galar \
  --extra-files extra-files \
  --generate-hardware-config nixos-facter ./nix/hosts/galar/facter.json \
  mint@192.168.x.x
```

**What this does:**
1.  Connects to the Mint user (you will need to type the password you set).
2.  Downloads the NixOS installer to RAM.
3.  **Wipes the disk** specified in `disk-config.nix`.
4.  Installs NixOS and copies the SSH key from `extra-files` so secrets work immediately.

##  Updates

Once the machine is deployed, you do **not** use `nixos-anywhere` again (unless you want to wipe it).

To apply configuration changes, use the convenience command in `justfile`:

```bash
just remote-switch galar
```

This effectively runs:
```bash
nixos-rebuild switch --flake .#galar --target-host root@galar.fenrir-altered.ts.net
```
(Using the Tailscale DNS name).
