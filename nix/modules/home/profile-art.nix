{ pkgs, ... }:
let
  # Import Krita AI Diffusion plugin via external flake
  # nix-comfyui = builtins.getFlake "github:dyscorv/nix-comfyui";
  # krita-with-ai = nix-comfyui.packages.${pkgs.system}.krita-with-extensions;
in
{
  # Enable or disable this block to turn on or off wonderdraft/other non-public packages
  # imports = 
  #   if builtins.pathExists ../../local/art-extras.nix 
  #   then [ ../../local/art-extras.nix ] 
  #   else [];

  # General Packages
  home.packages = with pkgs; [
    # Art
    krita  # ToDo: https://github.com/Acly/krita-ai-diffusion?tab=readme-ov-file
    # krita-with-ai
    gimp3
    inkscape

    # Media
    handbrake # Transcoding tool
  ];
}
