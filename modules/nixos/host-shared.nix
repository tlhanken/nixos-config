{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.btop
    pkgs.nano
  ];
  
  nixpkgs.config.allowUnfree = true; 
}
