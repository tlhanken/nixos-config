{ pkgs, inputs, flake, ... }:
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

    # Hardware Imports
    # ./hardware-configuration.nix

    # Additional NixOs modules from this flake
    flake.nixosModules.host-shared
    flake.modules.bootstrap.bootstrap
    flake.modules.bootstrapinstall.install
    flake.modules.desktop.desktop
    flake.modules.common.common
    flake.modules.apps.jellyfin
    flake.modules.apps.immich
    flake.modules.apps.homepage
  ];

  # ============================================================================
  # Host Identity & Networking
  # ============================================================================
  networking.hostName = "galar"; # Define your hostname.
  networking.hostId = "8425e349"; # Generate using `head -c 8 /etc/machine-id`

  # ============================================================================
  # System Basics
  # ============================================================================
  system.stateVersion = "25.05"; # initial nixos state
  nixpkgs.hostPlatform = "x86_64-linux";
  
  # Required for nixos-anywhere
  disko.devices = import ./disk-config.nix;

  # ============================================================================
  # Boot & Filesystems
  # ============================================================================
  boot.kernelModules = [ "kvm-intel" ];

  # ============================================================================
  # Host Features
  # ============================================================================
  # Enable Cross-Device Mounts
  my.mounts.media = {
    enable = true;
    mode = "local";
    localPath = "/mnt/local/media";
  };
  my.mounts.vault = {
    enable = true;
    mode = "local";
    localPath = "/mnt/local/vault";
  };

  # my.mounts.backup.enable = true;

  my.mounts.legacyPaths.enable = true;

  # Ensure local mount source dirs exist (non-destructive: 'd' only creates if missing)
  systemd.tmpfiles.rules = [
    "d /mnt/local       0755 root root -"
    "d /mnt/local/media 0755 root root -"
    "d /mnt/local/vault 0755 root root -"
  ];


  # ============================================================================
  # Environment
  # ============================================================================

  # ============================================================================
  # Services
  # ============================================================================
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /mnt/media 100.64.0.0/255.192.0.0(rw,no_subtree_check)
    /mnt/vault 100.64.0.0/255.192.0.0(rw,no_subtree_check)
  '';

  # Services.openssh is enabled in host-shared, but we ensure settings here
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
    hashedPassword = "$6$61Y4qra.nxzyVg.9$50lhU3Ni7k9bpv7lAmvsWlwQZUfRtvk9KAqrlHXyAX8AlPfD.LTc1pR635HhvOHks6/hDwoSiaYff6hyBPZNb."; # Hash of a password can be found with "mkpasswd -m sha-512"
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8Y+AKToEbNI9gyaC9yi6Y5OfZ38cP3wHYqbi2tmTu trevor.hanken@gmail.com"
    ];
  };
}