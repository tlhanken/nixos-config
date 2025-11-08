{ pkgs, inputs, ... }:
{

  imports = [ 
    inputs.self.nixosModules.01-bootstrap
    inputs.self.nixosModules.02-bootstrap
    inputs.self.nixosModules.common
    inputs.self.nixosModules.desktop
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
