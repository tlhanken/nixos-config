{ pkgs, inputs, lib, ... }:
let
  unstable = import ./profile-ai-unstable.nix {
    inherit inputs lib;
    system = pkgs.stdenv.hostPlatform.system;
  };
  openspec = import ./openspec.nix { inherit pkgs lib; };
in {
  home.packages = with pkgs; [
    unstable.code-cursor-fhs
    (unstable.antigravity-ide-fhs or unstable.antigravity-fhs)
    unstable.lmstudio

    nodejs
    python3
    uv

    openspec
  ];

  programs.gemini-cli.enable = true;
  programs.claude-code = {
    enable = true;
    package = unstable.claude-code;
  };

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      tailscale.vscode-tailscale
      ms-azuretools.vscode-containers
      Google.gemini-cli-vscode-ide-companion
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      ms-python.python
      ms-python.vscode-pylance
      ms-python.debugpy
    ];
  };

  programs.git.lfs.enable = true;

  programs.jujutsu = {
    settings = {
      aliases = {
        l = ["log" "-r" "(trunk()..@):: | (trunk()..@)-- | trunk()"];
        lwb = [
          "log"
          "-r"
          "ancestors(roots(trunk()..tracked_remote_bookmarks()),2) | ancestors(tracked_remote_bookmarks(),2) | trunk()"
        ];
        lub = [
          "log"
          "-r"
          "ancestors(roots(trunk()..untracked_remote_bookmarks()),2) | ancestors(untracked_remote_bookmarks(),2) | trunk()"
        ];
      };
      ui.paginate = "never";
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
