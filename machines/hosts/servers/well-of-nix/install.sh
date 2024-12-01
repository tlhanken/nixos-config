# sudo nixos-generate-config
# git clone https://github.com/tlhanken/nixos-config.git
# cp /etc/nixos/hardware-configuration.nix ~/nixos-config/machines/hosts/servers/syno-vm/
# lsblk
# Edit devices.nix
# Edit install script to use lsblk disk

sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes \
    run 'github:nix-community/disko#disko-install' -- \
    --flake '.#well-of-nix' \
    --disk boot /dev/sda/;

# Must manually export zpools as disko doesn't handle correctly
sudo zpool export zroot;
# sudo zpool export zflash;
# sudo zpool export zbulk;


# if you have a nix device you are starting from 
# nix run github:nix-community/nixos-anywhere -- \
#     --copy-host-keys \
#     --flake .#syno-vm \
#     root@192.168.20.96