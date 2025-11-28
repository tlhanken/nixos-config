{ pkgs, osConfig, ... }:

let 
  email = "trevor.hanken@gmail.com";
  name = "Trevor Hanken";
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
      xrandr

      #Util - GUI
      mission-center

      #Productivity
      bitwarden-desktop
      firefox
      google-chrome
      obsidian
      libreoffice-qt6-fresh
      kdePackages.ghostwriter
      # nextcloud-client

      #Art
      krita
      gimp3
      inkscape
      # wonderdraft  # Need to manually add to nix store: "nix-store --add-fixed sha256 Wonderdraft-1.1.8.2b-Linux64.deb"

      #Media
      # vlc
      # handbrake
      spotify

      #Dev
      vscode
      vscode-extensions.jnoortheen.nix-ide
      # vscode-extensions.rust-lang.rust-analyzer #Didn't work?
      # vscode-extensions.ms-azuretools.vscode-docker #Didn't work?
      # vscode-extensions.tamasfe.even-better-toml
      claude-code

      #AI
      # ollama
      # open-webui
      # librechat
      # n8n
      # qdrant?
      # qdrant-web-ui?
      # # TODO, ComfyUI for image gen?
    ];

  # Version Control
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        inherit name email;
      };
    };
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
