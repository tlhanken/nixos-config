{ pkgs, ... }:
let
  # Import Krita AI Diffusion plugin via external flake
  # nix-comfyui = builtins.getFlake "github:dyscorv/nix-comfyui";
  # krita-with-ai = nix-comfyui.packages.${pkgs.system}.krita-with-extensions;
in
{
  # imports = 
  #   if builtins.pathExists ../../local/art-extras.nix 
  #   then [ ../../local/art-extras.nix ] 
  #   else [];

  home.packages = with pkgs; [
    # Art
    krita  # ToDo: https://github.com/Acly/krita-ai-diffusion?tab=readme-ov-file
    # krita-with-ai
    gimp3
    inkscape
    # wonderdraft - Moved to ../../local/art-extras.nix
    # wonderdraft  # Need to manually add to nix store: "nix-store --add-fixed sha256 Wonderdraft-1.1.8.2b-Linux64.deb"


    # Media
    handbrake # Transcoding tool
  ];
}
