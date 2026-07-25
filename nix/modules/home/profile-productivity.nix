{ pkgs, ... }:
{
  imports = [ /* ./claude-desktop.nix */ ];
  
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "ui.systemUsesDarkTheme" = 1;
      };
    };
  };

  home.packages = with pkgs; [
    # Util - GUI
    mission-center
    baobab

    # Productivity
    bitwarden-desktop
    google-chrome
    libreoffice-qt6-fresh
    obsidian
    # kdePackages.ghostwriter
    # arrow
    synology-drive-client
    nextcloud-client

    # Media (Music)
    spotify
  ];
}
