{ pkgs, inputs, ... }:
{

  imports = [ 
    inputs.self.nixosModules.host-shared 
    inputs.self.nixosModules.users.tlhanken
    ./hardware-configuration.nix
  ];

  networking.hostName = "sleipnir"; # Define your hostname.
  networking.hostId = "52cad215"; # Generate using `head -c 8 /etc/machine-id`

  system.stateVersion = "25.05"; # initial nixos state
}
