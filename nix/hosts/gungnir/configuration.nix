{ pkgs, inputs, flake, ... }:
{
  imports = [
    # Standard modules
    inputs.disko.nixosModules.disko
    inputs.nixos-facter-modules.nixosModules.facter
    {
      config.facter.reportPath =
        if builtins.pathExists ./facter.json
        then ./facter.json
        else throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./facter.json`?";
    }

    # Hardware Support (Pending specific hardware module from nixos-hardware)
    # inputs.nixos-hardware.nixosModules.common-cpu-amd
    # inputs.nixos-hardware.nixosModules.common-gpu-amd

    # Shared modules
    flake.nixosModules.host-shared
    flake.modules.bootstrap.bootstrap
    flake.modules.bootstrapinstall.install
    flake.modules.desktop.desktop
    flake.modules.common.common # Assumed common configuration
    # flake.modules.apps.steam # specific apps can be enabled here
  ];

  # Disk Configuration
  disko.devices = import ./disk-config.nix;

  # Host Identity
  networking.hostName = "gungnir";
  networking.hostId = "8425e349"; # Randomly generated 8-char hex string

  # System State Version
  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  # Hardware Configuration (AMD 7800X3D + 7900 XTX)
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Corsair/RGB Support
  hardware.ckb-next.enable = true;
  services.hardware.openrgb.enable = true;
  environment.systemPackages = [ pkgs.ckb-next pkgs.openrgb-with-all-plugins pkgs.openlinkhub ];

  # Firmware
  services.fwupd.enable = true;

  # User Configuration
  users.users.tlhanken = {
    isNormalUser = true;
    description = "Trevor Hanken";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    hashedPassword = "$6$ixGyRfYdIHhH/Q1u$TeWo62eBKleB/qiiVjzDSR3syaGJPFpZQmXwCU2YM/KRiqSXXjDjv/apfE7lndzNxrCCHw4ywWKmY7UgGAm.T/"; # Hash of a password can be found with "mkpasswd -m sha-512"
  };
}
