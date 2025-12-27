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

      #Util - GUI
      mission-center

      #Productivity
      bitwarden-desktop
      firefox
      google-chrome
      libreoffice-qt6-fresh
      obsidian
      # kdePackages.ghostwriter
      # arrow
      # synology-drive-client
      # nextcloud-client

      #Art
      krita  # ToDo: https://github.com/Acly/krita-ai-diffusion?tab=readme-ov-file
      # krita-with-ai 
      gimp3
      inkscape
      wonderdraft  # Need to manually add to nix store: "nix-store --add-fixed sha256 Wonderdraft-1.1.8.2b-Linux64.deb"

      #Media
      handbrake # Transcoding tool
      spotify

      #Coding
      antigravity-fhs
      # gemini-cli
      claude-code
      python3
      uv

      #AI
      lmstudio
      # ollama
      # open-webui
      # librechat
      # n8n
      # qdrant?
      # qdrant-web-ui?
      # # TODO, ComfyUI for image gen?

      #Games
      # prismlauncher
      # worldpainter
    ];

  # VS Code
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      # Remote development & networking
      tailscale.vscode-tailscale

      # Docker
      ms-azuretools.vscode-containers

      # AI assistance
      # Google.gemini-cli-vscode-ide-companion
      # anthropic.claude-code
      kilocode.kilo-code
      
      # Nix development
      jnoortheen.nix-ide

      # Rust development
      rust-lang.rust-analyzer
      tamasfe.even-better-toml

      # Python development
      ms-python.python
      ms-python.vscode-pylance
      ms-python.debugpy

      # Git & version control
      # github.vscode-pull-request-github

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

  home.stateVersion = "25.05"; # initial home-manager state
}
