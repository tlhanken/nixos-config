{ config, lib, ... }:
let
  cfg = config.my.desktop;
in {
  config = lib.mkIf (cfg.session == "cinnamon") {
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.desktopManager.cinnamon.enable = true;
    services.cinnamon.apps.enable = true;
  };
}
