{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktop;
  gnomeEnabled = cfg.session == "gnome";
in {
  config = lib.mkIf gnomeEnabled {
    # Wayland session via GDM; Xwayland remains available for legacy apps.
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome = {
      enable = true;
      extraGSettingsOverridePackages = with pkgs; [
        gsettings-desktop-schemas
        gnome-shell
        mutter
      ];
      extraGSettingsOverrides =
        # Framework 12 panel is 1920x1200; enable fractional scale in Settings.
        ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer']

        [org.gnome.desktop.interface]
        gtk-theme='Adwaita-dark'
        color-scheme='prefer-dark'
        enable-hot-corners=false

        # Framework touchpad has physical click regions; fingers mode breaks LMB/RMB.
        [org.gnome.desktop.peripherals.touchpad]
        click-method='areas'

        [org.gnome.settings-daemon.plugins.media-keys]
        screensaver=['<Super>l', 'XF86ScreenSaver']

        [org.gnome.desktop.a11y.applications]
        screen-keyboard-enabled=false
        '';
    };

    # Framework Laptop 12 (import nixos-hardware framework-* on the host for firmware/audio).
    hardware.sensor.iio.enable = lib.mkDefault true;

    services.fwupd.enable = lib.mkDefault true;

    services.power-profiles-daemon.enable = lib.mkDefault true;

    # GNOME Shell auto-rotate uses iio-sensor-proxy on Wayland (replaces Cinnamon xrandr script).
    environment.systemPackages = with pkgs; [
      iio-sensor-proxy
      gnome-tweaks
    ];

    services.xserver.excludePackages = with pkgs; [xterm];
  };
}
