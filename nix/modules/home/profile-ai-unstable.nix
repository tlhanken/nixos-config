# Unstable nixpkgs with allowUnfree for AI/dev tools not yet on stable.
{ inputs, lib, system }:
import inputs.nixpkgs-unstable {
  inherit system;
  config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "docker-28.5.2"
      "electron-39.8.10"
    ];
  };
}
