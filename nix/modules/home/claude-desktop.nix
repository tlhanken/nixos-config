{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.claude-desktop-debian.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-fhs
  ];
}
