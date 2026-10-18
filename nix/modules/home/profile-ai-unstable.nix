# Unstable nixpkgs with allowUnfree for AI/dev tools not yet on stable.
{ inputs, lib, system }:
import inputs.nixpkgs-unstable {
  inherit system;
  config = {
    allowUnfree = true;
  };
}
