{ pkgs, osConfig, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # only available on linux, disabled on macos
  services.ssh-agent.enable = pkgs.stdenv.isLinux;

  home.packages =
    with pkgs; [ 
      #Util - Cmd
      which
      btop
      iotop
      iftop
    ];

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

