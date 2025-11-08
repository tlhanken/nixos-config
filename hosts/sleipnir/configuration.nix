{ pkgs, inputs, ... }:
{

  imports = [ 
    inputs.self.modules.bootstrap.bootstrap
    inputs.self.modules.bootstrapinstall.install
    inputs.self.modules.common.common
    inputs.self.modules.desktop.desktop
    ./hardware-configuration.nix

  ];

  networking.hostName = "sleipnir"; # Define your hostname.
  networking.hostId = "52cad215"; # Generate using `head -c 8 /etc/machine-id`

  system.stateVersion = "25.05"; # initial nixos state

  users.users.tlhanken.isNormalUser = true;

  services.fwupd.enable = true;

  # Temp
  boot.loader.grub.enable = pkgs.lib.mkDefault false;

}
