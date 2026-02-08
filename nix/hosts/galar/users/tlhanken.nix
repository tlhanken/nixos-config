{ pkgs, inputs, ... }:
let
  name = "Trevor Hanken";
  email = "trevor.hanken@gmail.com";
in
{  
  imports = [ 
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.profile-productivity
    inputs.self.homeModules.user-tlhanken
    ];

  # on nixos this either isNormalUser or isSystemUser is required to create the user.
  # home.homeDirectory = "/home/tlhanken";

  # Identity
  programs.git = {
    enable = true;
    userName = name;
    userEmail = email;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        inherit name email;
      };
    };
  };
}