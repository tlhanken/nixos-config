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
  ];

  # Required for nixos-anywhere
  disko.devices = import ./disk-config.nix;
  networking.hostName = "galar"; # Define your hostname.
  networking.hostId = "8425e349"; # Generate using `head -c 8 /etc/machine-id`

  boot.kernelModules = [ "kvm-intel" ];

  system.stateVersion = "25.05"; # initial nixos state

  boot.supportedFilesystems = [ "nfs" ];
  environment.systemPackages = [ pkgs.nfs-utils ];

  systemd.mounts = [{
    type = "nfs";
    mountConfig = {
      Options = "ro,noauto";
    };
    what = "well-of-mimir.fenrir-altered.ts.net:/volume1/media";
    where = "/mnt/well-of-mimir/media";
  }];

  systemd.automounts = [{
    wantedBy = [ "multi-user.target" ];
    automountConfig = {
      TimeoutIdleSec = "600";
    };
    where = "/mnt/well-of-mimir/media";
  }];

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
  
  # Services.openssh is enabled in host-shared, but we ensure settings here
  services.openssh = {
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
}