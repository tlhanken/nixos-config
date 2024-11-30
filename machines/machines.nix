{inputs, ...}:
with inputs; let
  home = [
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.tlhanken = import ./modules/users/tlhanken/home-manager.nix;
      };
    }
  ];
  users = [./modules/users/users.nix];

  secrets = [agenix.nixosModules.default ../secrets/mod.nix];

  # Apply to all hosts, including bootstrap images
  bootstrap_mods = [./modules/bootstrap/bootstrap.nix] ++ users;

  # Apply to all hosts, including hosts being adopted
  install_mods = [disko.nixosModules.disko ./modules/install/install.nix] ++ bootstrap_mods;

  # Apply to all activated hosts
  common_mods = [./modules/common/common.nix] ++ install_mods ++ secrets;

  # Apply to only servers
  server_mods = [./modules/server/server.nix] ++ common_mods;

  # Apply to only desktops
  desktop_mods = [./modules/desktop/desktop.nix] ++ common_mods ++ home;
in {
  flake = {
    nixosConfigurations = {
      # Desktops
      # TODO
      # gungnir = inputs.nixpkgs.lib.nixosSystem {
      #   modules = [./hosts/desktops/gungnir/configuration.nix] ++ desktop_mods;
      # };
      # surface6 = inputs.nixpkgs.lib.nixosSystem {
      #   modules = [./hosts/desktops/surface6/configuration.nix] ++ desktop_mods;
      # };

      # Servers
      # TODO
      # galar = inputs.nixpkgs.lib.nixosSystem {
      #   modules = [./hosts/desktops/surface6/configuration.nix] ++ server_mods;
      # };
      # eitri = inputs.nixpkgs.lib.nixosSystem {
      #   modules = [./hosts/desktops/eitri/configuration.nix] ++ server_mods;
      # };
      # brokkr = inputs.nixpkgs.lib.nixosSystem {
      #   modules = [./hosts/desktops/brokkr/configuration.nix] ++ server_mods;
      # };
      # nixos-rpi4-1 = inputs.nixpkgs.lib.nixosSystem {
      #   modules =
      #     [
      #       ./hosts/servers/nixos-rpi4-1/configuration.nix
      #       inputs.nixos-hardware.nixosModules.raspberry-pi-4
      #     ]
      #     ++ server_mods;
      # };
      # syno-vm = inputs.nixpkgs.lib.nixosSystem {
      #   modules = [./hosts/servers/syno-vm/configuration.nix] ++ server_mods;
      # };
    };
  };
  perSystem = {
    packages = let
      bootstrap_modules = [./hosts/utils/nixos-bootstrap/configuration.nix] ++ bootstrap_mods;
    in {
      nixos-vm-bootstrap-image = inputs.nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        modules = bootstrap_modules;
        format = "iso";
      };
      # To burn image: sudo zstd -cd ./result/sd-image/{img}.img.zst | sudo dd bs=1M of=/dev/sdX status=progress
      nixos-rpi-bootstrap-image = inputs.nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        modules = bootstrap_modules;
        format = "sd-aarch64";
      };
    };
  };
}
