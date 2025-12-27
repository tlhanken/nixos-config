{pkgs, ... }:
{
  # Desktop Environment Settings
  dconf.settings = {
    "org/cinnamon/desktop/background" = {
      picture-uri = "file://${../../../backgrounds/1920x1200/sunset_mountain_lake.jpg}";
      picture-options = "zoom";
    };
    "org/cinnamon/desktop/screensaver" = {
      picture-uri = "file://${../../../backgrounds/1920x1200/fuji.jpg}";
      picture-options = "zoom";
    };
  };
}