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
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
    # ./hardware-configuration.nix

    # Additional NixOs modules from this flake
    flake.nixosModules.host-shared
    flake.modules.bootstrap.bootstrap
    flake.modules.bootstrapinstall.install
    flake.modules.desktop.desktop
    flake.modules.common.common
    flake.modules.apps.jellyfin
    flake.modules.apps.steam
    flake.modules.apps.rust
  ];

  # Required for nixos-anywhere
  disko.devices = import ./disk-config.nix;
  networking.hostName = "sleipnir"; # Define your hostname.
  networking.hostId = "52cad215"; # Generate using `head -c 8 /etc/machine-id`

  system.stateVersion = "25.05"; # initial nixos state

  # Firmware and bootloader
  services.fwupd.enable = true;
  # Temporary fix for accelerometer data rotating desktop when in tent mode on framework 12: https://github.com/FrameworkComputer/linux-docs/blob/main/framework12/nixOS.md
  boot.initrd.kernelModules = [ "pinctrl_tigerlake" ];
  nixpkgs.overlays = [
  (final: prev: {
    iio-sensor-proxy = prev.iio-sensor-proxy.overrideAttrs (oldAttrs: {
      postPatch = oldAttrs.postPatch + ''
      sed -i -e 's/.*iio-buffer-accel/#&/' data/80-iio-sensor-proxy.rules
      '';
    });
  })
];

users.users.tlhanken = {
    isNormalUser = true;
    description = "Trevor Hanken";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    hashedPassword = "$6$QwxrgyqftaIVyPRS$1BcH0tM8DbFEzzvYcsz7AeQvZImxUUxwyj0SVYCpvZZTZ1BtKjlrUTg3ydGIX9doSKCOw/M91Y11ZtAaQZuPD1"; # Hash of a password can be found with "mkpasswd -m sha-512"
  };

}
