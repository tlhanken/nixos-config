{ pkgs, ... }:
{
  # Enable or disable this block to turn on or off wonderdraft/other non-public packages
  imports = 
    if builtins.pathExists ../../local/art-extras.nix 
    then [ ../../local/art-extras.nix ] 
    else [];

  # General Packages
  home.packages = with pkgs; [
    # Art
    krita
    gimp3
    inkscape

    # Media
    handbrake # Transcoding tool
  ];
}
