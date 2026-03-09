{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.claude-desktop-debian.packages.${pkgs.system}.claude-desktop-fhs
  ];
}
