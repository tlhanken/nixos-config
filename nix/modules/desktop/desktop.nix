{ pkgs, ... }:
{
  imports = [
    ./networking.nix
    ./sound.nix
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  services.cinnamon.apps.enable = true;

  # Configure Cinnamon default theme (dark mode with teal theme)
  services.xserver.desktopManager.cinnamon.sessionPath = [ 
    (pkgs.writeTextFile {
      name = "cinnamon-theme-config";
      destination = "/etc/xdg/autostart/cinnamon-theme-config.desktop";
      text = ''
        [Desktop Entry]
        Name=Cinnamon Theme Config
        Exec=${pkgs.glib}/bin/gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Teal' && ${pkgs.glib}/bin/gsettings set org.cinnamon.theme name 'Mint-Y-Dark-Teal' && ${pkgs.glib}/bin/gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Teal' && ${pkgs.glib}/bin/gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-Y-Dark-Teal'
        Type=Application
        Hidden=false
        NoDisplay=false
        X-GNOME-Autostart-enabled=true
      '';
    })
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.graphics = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs.trayscale
  ];
}