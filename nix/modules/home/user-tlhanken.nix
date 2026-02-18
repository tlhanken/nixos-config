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
    "org/cinnamon/desktop/interface" = {
      gtk-theme = "Mint-Y-Dark-Teal";
      icon-theme = "Mint-Y-Teal";
    };
    "org/cinnamon/theme" = {
      name = "Mint-Y-Dark-Teal";
    };
    "org/cinnamon/desktop/wm/preferences" = {
      theme = "Mint-Y-Dark-Teal";
    };
    "org/cinnamon/desktop/keybindings/media-keys" = {
      screensaver = ["<Super>l" "XF86ScreenSaver"];
    };
    "org/cinnamon/desktop/keybindings/vm" = {
      looking-glass-key = ["<Super>F12"];
    };
  };

  xdg.configFile."autostart/trayscale.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Trayscale
    Exec=${pkgs.trayscale}/bin/trayscale --hide-window
    Icon=trayscale
    Comment=Trayscale
    X-GNOME-Autostart-enabled=true
  '';
}