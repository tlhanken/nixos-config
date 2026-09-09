{ config, lib, pkgs, ... }:
let
  identity = config.home.userIdentity;
in {
  options.home.userIdentity = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Display name for git and jujutsu (set in host users/*.nix)";
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Email for git and jujutsu (set in host users/*.nix)";
    };
  };

  config = {
    # allowUnfree is set on the NixOS host (host-shared); HM uses global pkgs.
    services.ssh-agent.enable = pkgs.stdenv.hostPlatform.isLinux;

    home.packages = with pkgs; [
      which
      btop
      iotop
      iftop
    ];

    programs.bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        gitprune = "git fetch -p ; git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -D";
        gitsync = "git checkout main; git pull; gitprune;";
      };
    };

    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };

    programs.git = lib.mkIf (identity.name != "" && identity.email != "") {
      enable = true;
      settings = {
        user.name = identity.name;
        user.email = identity.email;
      };
    };

    programs.jujutsu = lib.mkIf (identity.name != "" && identity.email != "") {
      enable = true;
      settings.user = {
        name = identity.name;
        email = identity.email;
      };
    };

    # Pin to the Home Manager release when profiles were first applied; do not match nixpkgs channel.
    home.stateVersion = "25.05";
  };
}
