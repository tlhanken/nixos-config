{ pkgs, inputs, ... }:
{  
  imports = [ inputs.self.homeModules.home-shared ];

  # on nixos this either isNormalUser or isSystemUser is required to create the user.
  users.users.tlhanken.isNormalUser = true;
  home.username = "tlhanken";
  home.homeDirectory = "/home/tlhanken";
}