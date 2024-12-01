# nixos-config
NixOS configuration for home devices

## Getting Started/Setup
* Github
* Garnix account and tie to gitlab
* Github App and add key to github repo's secret on the web portal.  App permissions, and add to repo.

## Good Commands in dev portal
### Utils
* nix fmt
    Format nix files
### Configs
* nix flake check
    Runs tests
* nix flake show
    Show all packages and defines.  
* nix flake metadata
    Inputs defined, make sure they follow eachother.  Otherwise you have double dependencies (which could be intentended in some situations)
### Builds
* nh os build .
    Builds current system for current hostname.  Using local copy of nix config.
* nh os build .#{other hostname}
    Build a target by hostname {other hostname}.
* nh os build github:tlhanken/nixos-config/{branch}#{other hostname}
    Built {other hostname} using copy of nixos config on {branch}
* nh os test .
    Build followed by activation in current session.  Doesn't persist on reboot cycle.  
* nh os boot .
    Build, keep current for now, and activate on the next boot (and thereafter).
* nh os switch .
    Build, activate on current session, and active on future boots.
