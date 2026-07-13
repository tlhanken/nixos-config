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
  ];

  # ============================================================================
  # Host Identity & Networking
  # ============================================================================
  networking.hostName = "well-of-mimir"; # Define your hostname.
  networking.hostId = "c76cad63"; # Generated using `openssl rand -hex 4`

  # ============================================================================
  # System Basics
  # ============================================================================
  # Pin to the NixOS release when this host was first installed; do not match nixpkgs channel.
  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  # Required for nixos-anywhere
  disko.devices = import ./disk-config.nix;

  # ============================================================================
  # Desktop (Temporary for setup)
  # ============================================================================
  my.desktop.session = "cinnamon";

  # ============================================================================
  # Host Features
  # ============================================================================
  # Enable Cross-Device Mounts
  my.mounts.legacyPaths.enable = true;

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
    hashedPassword = "$6$61Y4qra.nxzyVg.9$50lhU3Ni7k9bpv7lAmvsWlwQZUfRtvk9KAqrlHXyAX8AlPfD.LTc1pR635HhvOHks6/hDwoSiaYff6hyBPZNb."; # Copied from galar
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8Y+AKToEbNI9gyaC9yi6Y5OfZ38cP3wHYqbi2tmTu trevor.hanken@gmail.com"
    ];
  };
}
