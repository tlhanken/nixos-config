{ inputs, ... }:
{
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.profile-productivity
    inputs.self.homeModules.user-tlhanken
  ];

  home.userIdentity = {
    name = "Trevor Hanken";
    email = "trevor.hanken@gmail.com";
  };
}