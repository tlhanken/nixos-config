{ pkgs, inputs, ... }:
{  
  imports = [ inputs.self.homeModules.home-shared ];

  # on nixos this either isNormalUser or isSystemUser is required to create the user.
  # home.homeDirectory = "/home/tlhanken";
}