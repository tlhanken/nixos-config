{ config, lib, pkgs, ... }:
let
  cfg = config.my.desktop;
in {
  options.my.desktop = {
    session = lib.mkOption {
      type = lib.types.enum ["cinnamon" "gnome"];
      default = "cinnamon";
      description = "Desktop session. Set to gnome and import gnome.nix to use GNOME instead of Cinnamon.";
    };
  };

  imports = [
    ./networking.nix
    ./sound.nix
    ./cinnamon.nix
    # ./gnome.nix
  ];

  config = {
    services.xserver.enable = cfg.session == "cinnamon";

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    services.printing.enable = true;

    hardware.graphics.enable = true;

    environment.systemPackages = [pkgs.trayscale];
  };
}
