{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  backgroundsDir = ../../../backgrounds;
  resolution = "1920x1200";
  desktopFile = "${resolution}/sunset_mountain_lake.jpg";
  screensaverFile = "${resolution}/fuji.jpg";
  desktopSrc = "${backgroundsDir}/${desktopFile}";
  screensaverSrc = "${backgroundsDir}/${screensaverFile}";
  hasDesktopBg = builtins.pathExists desktopSrc;
  hasScreensaverBg = builtins.pathExists screensaverSrc;
  wallpaperDir = "${config.home.homeDirectory}/.local/share/wallpapers";
  desktopInstalled = "${wallpaperDir}/desktop.jpg";
  screensaverInstalled = "${wallpaperDir}/screensaver.jpg";
  cinnamonSession = (osConfig.my.desktop.session or "cinnamon") == "cinnamon";
  gnomeSession = (osConfig.my.desktop.session or "cinnamon") == "gnome";
in {
  home.file = lib.mkMerge [
    (lib.mkIf hasDesktopBg {
      "${wallpaperDir}/desktop.jpg".source = desktopSrc;
    })
    (lib.mkIf hasScreensaverBg {
      "${wallpaperDir}/screensaver.jpg".source = screensaverSrc;
    })
  ];

  home.packages = lib.mkIf gnomeSession [
    pkgs.gnomeExtensions.appindicator
  ];

  dconf.settings = lib.mkMerge [
    (lib.mkIf cinnamonSession {
      "org/cinnamon/desktop/background" = lib.mkIf hasDesktopBg {
        picture-uri = "file://${desktopInstalled}";
        picture-options = "zoom";
      };
      "org/cinnamon/desktop/screensaver" = lib.mkIf hasScreensaverBg {
        picture-uri = "file://${screensaverInstalled}";
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
      "org/cinnamon/desktop/keybindings/media-keys".screensaver = [
        "<Super>l"
        "XF86ScreenSaver"
      ];
      "org/cinnamon/desktop/keybindings/vm".looking-glass-key = ["<Super>F12"];
    })
    (lib.mkIf gnomeSession {
      "org/gnome/desktop/background" = lib.mkIf hasDesktopBg {
        picture-uri = "file://${desktopInstalled}";
        picture-uri-dark = "file://${desktopInstalled}";
        picture-options = "zoom";
      };
      "org/gnome/desktop/screensaver" = lib.mkIf hasScreensaverBg {
        picture-uri = "file://${screensaverInstalled}";
        picture-uri-dark = "file://${screensaverInstalled}";
        picture-options = "zoom";
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };
      "org/gnome/desktop/interface" = {
        clock-show-weekday = true;
        clock-show-date = true;
        clock-format = "12h";
        text-scaling-factor = 0.8;
        icon-theme = "Adwaita";
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" ];
        favorite-apps = [
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
          "org.gnome.Console.desktop"
        ];
      };
      "org/gnome/desktop/wm/keybindings" = {
        switch-windows = ["<Alt>Tab"];
        switch-windows-backward = ["<Shift><Alt>Tab"];
        switch-applications = [];
        switch-applications-backward = [];
      };
    })
    {
      "org/gnome/desktop/a11y/applications".screen-keyboard-enabled = false;
    }
  ];

  xdg.configFile."autostart/trayscale.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Trayscale
    Exec=${pkgs.trayscale}/bin/trayscale --hide-window
    Icon=trayscale
    Comment=Trayscale
    X-GNOME-Autostart-enabled=true
  '';

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
  };
}
