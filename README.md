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

* nh os build .
    Build this config, which should also validate it.
* nh os test .
    Test this target's config on this computer in a volatile fashion
* nh os test .#nixosConfigurations.sleipnir
    Test the sleipnir config on this computer in a volatile fashion
* nh os switch .#nixosConfigurations.sleipnir
    Update to the sleipnir config on this computer
* nh os switch .
    Update the config of this computer to the config matching the hostname

## Create new host
* `nixos-anywhere root@<ip> -f .#<config-name> --generate-hardware-config nixos-facter ./nix/hosts/<host-name>/facter.json`


## Next up
* secrets
* tailscale
* apps
* cleanup
* extra user groups
* common.nix
* disk encryption
* galar device
