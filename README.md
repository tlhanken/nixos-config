# nixos-config
NixOS configuration for home devices

## Getting Started/Setup
* Github
* Garnix account and tie to gitlab
* Github App and add key to github repo's secret on the web portal.  App permissions, and add to repo.

## Good Commands in dev portal
* nix flake check
    Runs tests
* nix flake show
    Show all packages and defines.  
* nix flake metadata
    Inputs defined, make sure they follow eachother.  Otherwise you have double dependencies (which could be intentended in some situations)