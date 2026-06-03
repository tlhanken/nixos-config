{ inputs, ... }:
{
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.profile-hermes
    inputs.self.homeModules.profile-art
    inputs.self.homeModules.profile-productivity
    inputs.self.homeModules.profile-development
    inputs.self.homeModules.user-tlhanken
  ];

  home.userIdentity = {
    name = "Trevor Hanken";
    email = "trevor.hanken@gmail.com";
  };
}
