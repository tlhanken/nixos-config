{ pkgs, osConfig, ... }:

let
  email = "trevor.hanken@gmail.com";
  name = "Trevor Hanken";

  # Import Krita AI Diffusion plugin via external flake
  # nix-comfyui = builtins.getFlake "github:dyscorv/nix-comfyui";
  # krita-with-ai = nix-comfyui.packages.${pkgs.system}.krita-with-extensions;
in
{

  # only available on linux, disabled on macos
  services.ssh-agent.enable = pkgs.stdenv.isLinux;

  home.packages =
    with pkgs; [ 
      #Util - Cmd
      which
      btop
      iotop
      iftop
      # xrandr

      #Util - GUI
      mission-center

      #Productivity
      bitwarden-desktop
      firefox
      google-chrome
      obsidian
      libreoffice-qt6-fresh
      # kdePackages.ghostwriter
      # nextcloud-client

      #Art
      krita  # Replace with krita-with-ai below for AI Diffusion plugin
      # krita-with-ai # Krita with AI Diffusion plugin (from external flake)
      gimp3
      inkscape
      # wonderdraft  # Need to manually add to nix store: "nix-store --add-fixed sha256 Wonderdraft-1.1.8.2b-Linux64.deb"

      #Media
      # vlc # Media player
      # mpv
      # celluloid
      handbrake # Transcoding tool
      spotify

      #Dev
      claude-code
      python3
      uv

      #AI
      # ollama
      # open-webui
      # librechat
      # n8n
      # qdrant?
      # qdrant-web-ui?
      # # TODO, ComfyUI for image gen?

      #Games
      # prismlauncher
    ];

  # VS Code
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      # Nix development
      jnoortheen.nix-ide

      # Rust development
      rust-lang.rust-analyzer
      tamasfe.even-better-toml

      # Docker
      ms-azuretools.vscode-docker

      # AI assistance
      # anthropic.claude-code

      # Remote development & networking
      tailscale.vscode-tailscale

      # Git & version control
      # github.vscode-pull-request-github
      # eamodio.gitlens

      # Code quality & formatting
      # editorconfig.editorconfig

      # Utilities
      # usernamehw.errorlens
      # gruntfuggly.todo-tree
    ];
  };

  # Version Control
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = name;
    userEmail = email;
  };
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        inherit name email;
      };
      aliases = {
        # Current branch
        l = ["log" "-r" "(trunk()..@):: | (trunk()..@)-- | trunk()"];

        # Branches on local machine and github
        lwb = ["log" "-r" "ancestors(roots(trunk()..tracked_remote_bookmarks()),2) | ancestors(tracked_remote_bookmarks(),2) | trunk()"];

        # Branches not on local machine, but on github
        lub = ["log" "-r" "ancestors(roots(trunk()..untracked_remote_bookmarks()),2) | ancestors(untracked_remote_bookmarks(),2) | trunk()"];
      };
      ui = {
        paginate = "never";
      };
    };
  };

  # Directory enviroments
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # Terminals
  ## Bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      gitprune = "git fetch -p ; git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -D";
      gitsync = "git checkout main; git pull; gitprune;";
    };
  };
  ## Starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  # Desktop Environment Settings
  dconf.settings = {
    "org/cinnamon/desktop/background" = {
      picture-uri = "file:///home/tlhanken/Workspace/nixos-config/backgrounds/1920x1200/sunset_mountain_lake.jpg";
      picture-options = "zoom";
    };
    "org/cinnamon/desktop/screensaver" = {
      picture-uri = "file:///home/tlhanken/Workspace/nixos-config/backgrounds/1920x1200/fuji.jpg";
      picture-options = "zoom";
    };
  };



  home.stateVersion = "25.05"; # initial home-manager state
}
