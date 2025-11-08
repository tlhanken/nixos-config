{ pkgs, inputs, ... }:
{

  imports = [ 
    inputs.self.nixosModules.host-shared 
    ./hardware-configuration.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # on nixos this either isNormalUser or isSystemUser is required to create the user.
  users.users.tlhanken.isNormalUser = true;

  system.stateVersion = "25.05"; # initial nixos state
}
