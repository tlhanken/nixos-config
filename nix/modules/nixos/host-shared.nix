# Shared baseline for every managed host: Nix, SSH, Tailscale secret wiring,
# GRUB+ZFS boot, ZFS maintenance, and low-priority CLI tools.
# Install-time-only essentials stay in modules.bootstrap.bootstrap.
{
  lib,
  pkgs,
  modulesPath,
  config,
  inputs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.agenix.nixosModules.default
  ];

  config = {
    home-manager.backupFileExtension = "backup";

    services.tailscale_user.auth_key_path = config.age.secrets."tailscale_key".path;

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = map lib.lowPrio [
      pkgs.curl
      pkgs.git
      pkgs.nano
      pkgs.wget
    ];
    environment.variables.EDITOR = "nano";

    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8Y+AKToEbNI9gyaC9yi6Y5OfZ38cP3wHYqbi2tmTu trevor.hanken@gmail.com"
    ];

    nix.settings = {
      connect-timeout = 1;
      download-attempts = 1;
      log-lines = 25;
      max-jobs = "auto";
      min-free = 128000000;
      max-free = 1000000000;
      fallback = true;
      warn-dirty = false;
      keep-outputs = true;
      auto-optimise-store = true;

      experimental-features = ["nix-command" "flakes"];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };

    nix.extraOptions = ''
      !include ${config.age.secrets.github-token.path}
    '';

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 5";
    };

    # Canonical ZFS + GRUB layout for Disko hosts. Override via customBoot.enable
    # in bootstrapinstall/bootloader.nix only for non-standard installs.
    boot = {
      supportedFilesystems = ["zfs"];
      zfs.devNodes = "/dev/disk/by-partlabel";
      loader.grub = {
        enable = true;
        configurationLimit = 10;
        zfsSupport = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        mirroredBoots = [
          {
            devices = ["nodev"];
            path = "/boot";
          }
        ];
      };
    };

    services.zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };
  };
}
