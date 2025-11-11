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
      #Util
      which
      btop
      iotop
      iftop
      xrandr

      #Productivity
      firefox
      google-chrome

      #Art
      krita
      gimp3
      inkscape
      # wonderdraft  # Need to manually add to nix store: "nix-store --add-fixed sha256 Wonderdraft-1.1.8.2b-Linux64.deb"

      #Dev
      vscode
      vscode-extensions.jnoortheen.nix-ide
      vscode-extensions.rust-lang.rust-analyzer
      vscode-extensions.ms-azuretools.vscode-docker
      # vscode-extensions.tamasfe.even-better-toml
      claude-code
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

  

  home.stateVersion = "25.05"; # initial home-manager state
}
