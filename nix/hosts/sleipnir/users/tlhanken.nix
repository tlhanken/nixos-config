{ pkgs, inputs, ... }:
{  
  imports = [ 
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.user-tlhanken
    ];

  # on nixos this either isNormalUser or isSystemUser is required to create the user.
  # home.homeDirectory = "/home/tlhanken";
}