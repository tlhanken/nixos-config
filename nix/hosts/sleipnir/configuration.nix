{ pkgs, inputs, ... }:
{

  imports = [
    inputs.self.modules.bootstrap.bootstrap
    inputs.self.modules.bootstrapinstall.install
    inputs.self.modules.desktop.desktop
    inputs.self.modules.common.common
    inputs.self.modules.apps.jellyfin
    inputs.self.modules.apps.steam
    inputs.self.modules.apps.rust
    ./hardware-configuration.nix
  ];

  networking.hostName = "sleipnir"; # Define your hostname.
  networking.hostId = "52cad215"; # Generate using `head -c 8 /etc/machine-id`

  system.stateVersion = "25.05"; # initial nixos state

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

  # Firmware and bootloader
  services.fwupd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.overlays = [
  (final: prev: {
    iio-sensor-proxy = prev.iio-sensor-proxy.overrideAttrs (oldAttrs: {
      postPatch = oldAttrs.postPatch + ''
      sed -i -e 's/.*iio-buffer-accel/#&/' data/80-iio-sensor-proxy.rules
      '';
    });
  })
];

}
