{ pkgs, ... }:
let
  # Import Krita AI Diffusion plugin via external flake
  # nix-comfyui = builtins.getFlake "github:dyscorv/nix-comfyui";
  # krita-with-ai = nix-comfyui.packages.${pkgs.system}.krita-with-extensions;
in
{
  home.packages = with pkgs; [
    # Art
    krita  # ToDo: https://github.com/Acly/krita-ai-diffusion?tab=readme-ov-file
    # krita-with-ai
    gimp3
    inkscape
    wonderdraft  # Need to manually add to nix store: "nix-store --add-fixed sha256 Wonderdraft-1.1.8.2b-Linux64.deb"

    # Media
    handbrake # Transcoding tool
  ];
}
