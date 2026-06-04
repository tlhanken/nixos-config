{ pkgs, inputs, lib, ... }:
let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "antigravity"
        "claude-code"
        "code"
        "cursor"
        "lmstudio"
        "vscode"
      ];
  };
in {
  home.packages = with pkgs; [
    # AI Code Tools
    unstable.code-cursor-fhs
    unstable.antigravity-fhs
    unstable.lmstudio

    # Node.js
    nodejs

    # Python
    python3
    uv

    # AI (Services managed system-wide in nix/modules/apps/)
  ];

  programs.gemini-cli.enable = true;
  programs.claude-code = {
    enable = true;
    package = unstable.claude-code;
  };

  # VS Code
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      # Remote development & networking
      tailscale.vscode-tailscale

      # Docker
      ms-azuretools.vscode-containers

      # AI assistance
      Google.gemini-cli-vscode-ide-companion
      # anthropic.claude-code
      # kilocode.kilo-code
      
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
  };
  programs.jujutsu = {
    enable = true;
    settings = {
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
}
