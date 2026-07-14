{ pkgs, inputs, ... }:
{
  imports = [
    # Standard nixos-anywhere modules
    inputs.disko.nixosModules.disko
    inputs.nixos-facter-modules.nixosModules.facter
    {
      config.facter.reportPath =
        if builtins.pathExists ./facter.json
        then ./facter.json
        else throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./facter.json`?";
    }

    # Additional NixOS modules from this flake (see CLAUDE.md)
    inputs.self.modules.nixos.host-shared
    inputs.self.modules.bootstrap.bootstrap
    inputs.self.modules.bootstrapinstall.install
    inputs.self.modules.desktop.desktop
    inputs.self.modules.common.common

    # Server applications
    inputs.self.modules.apps.nginx
    inputs.self.modules.apps.immich
    # inputs.self.modules.apps.nextcloud
    inputs.self.modules.apps.it-tools
    inputs.self.modules.apps.homepage
    inputs.self.modules.apps.comfyui
    # inputs.self.modules.apps.open-webui
  ];

  # ============================================================================
  # Host Identity & Networking
  # ============================================================================
  networking.hostName = "well-of-mimir"; # Define your hostname.
  networking.hostId = "c76cad63"; # Generated using `openssl rand -hex 4`

  # ============================================================================
  # System Basics
  # ============================================================================
  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  disko.devices = import ./disk-config.nix;

  # ============================================================================
  # Boot & Filesystems
  # ============================================================================
  boot.kernelModules = [ "kvm-amd" ];

  # ============================================================================
  # Storage — NAS for the fleet
  # ============================================================================
  # Media stays local on galar (its own drive). Vault and AI live here.

  my.mounts.legacyPaths = {
    enable = true;
  };

  my.mounts.vault = {
    enable = true;
    mode = "local";
    localPath = "/mnt/local/vault";
  };

  my.mounts.ai = {
    enable = true;
    mode = "local";
    localPath = "/mnt/local/ai";
    exportNfs = true;
    nfsClientIps = [
      "100.109.178.115" # sleipnir
      "100.67.158.77"   # galar
    ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/local      0755 root root -"
    "d /mnt/local/vault 0755 root root -"
  ];

  # NFS server — export vault and AI to the Tailscale network
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /mnt/vault 100.64.0.0/255.192.0.0(rw,no_subtree_check)
  '';

  # ============================================================================
  # AI Services
  # ============================================================================
  # ComfyUI: runs on NAS; models on /mnt/ai, state in /mnt/local/appdata.
  my.comfyui = {
    enable = true;
    cpuOnly = true;
    sharedModels = true;
    expose = "tailscale";
    dataDir = "/mnt/local/appdata/comfyui";
    useStateDirectory = false;
  };

  # ============================================================================
  # Desktop
  # ============================================================================
  my.desktop.session = "cinnamon";

  # ============================================================================
  # SSH
  # ============================================================================
  services.openssh = {
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # ============================================================================
  # Users
  # ============================================================================
  users.users.tlhanken = {
    isNormalUser = true;
    description = "Trevor Hanken";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    hashedPassword = "$6$61Y4qra.nxzyVg.9$50lhU3Ni7k9bpv7lAmvsWlwQZUfRtvk9KAqrlHXyAX8AlPfD.LTc1pR635HhvOHks6/hDwoSiaYff6hyBPZNb."; # Copied from galar
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8Y+AKToEbNI9gyaC9yi6Y5OfZ38cP3wHYqbi2tmTu trevor.hanken@gmail.com"
    ];
  };
}
