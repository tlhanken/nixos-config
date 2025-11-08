{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.btop
    pkgs.nano
  ];
}
