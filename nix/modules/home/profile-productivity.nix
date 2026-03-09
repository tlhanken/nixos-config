{ pkgs, ... }:
{
  imports = [ ./claude-desktop.nix ];
  home.packages = with pkgs; [
    # Util - GUI
    mission-center
    baobab

    # Productivity
    bitwarden-desktop
    firefox
    google-chrome
    libreoffice-qt6-fresh
    obsidian
    # kdePackages.ghostwriter
    # arrow
    # synology-drive-client
    # nextcloud-client

    # Media (Music)
    spotify
  ];
}
