{ pkgs, ... }:
{
  home.packages = [ pkgs.wonderdraft ]; # # Need to manually add to nix store: "nix-store --add-fixed sha256 Wonderdraft-1.1.8.2b-Linux64.deb"
}
