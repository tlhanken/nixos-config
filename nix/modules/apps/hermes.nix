{ pkgs, inputs, config, lib, ... }:
let
  qmd = pkgs.callPackage ../../packages/qmd.nix { };
in {
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    # ── Secrets ────────────────────────────────────────────────────────
    # API keys (OPENROUTER_API_KEY, ANTHROPIC_API_KEY, etc.) are never
    # embedded in Nix — they live in the agenix-managed env file.
    # NOTE: To use Telegram, you must add TELEGRAM_BOT_TOKEN="<your_token>" to this secrets file.
    environmentFiles = [ config.age.secrets.ai-api-keys.path ];

    # ── Declarative Settings ───────────────────────────────────────────
    settings = {
      model = {
        default = "openrouter/deepseek/deepseek-v4-flash";
      };
      toolsets = [ "bash" "filesystem" "searxng" ];
      terminal = {
        # The agent boots into the root of its appdata (where SOUL.md lives)
        cwd = "/mnt/local/appdata/hermes";
      };
      agent = {
        max_steps = 30;
      };
      compression = {
        enabled = true;
        threshold = 0.75;
      };
    };



    # ── Packages & Dependencies ────────────────────────────────────────
    # Inject tools directly into the agent's isolated PATH
    extraPackages = with pkgs; [
      searxng
      qmd
      git
    ];



    # ── Scrapling ──────────────────────────────────────────────────────
    # TODO: Scrapling needs to be packaged via Nix (extraPythonPackages) 
    # or installed directly into the hermes user's environment. 
    # Hardcoding a path to /home/tlhanken breaks isolation.
    environment = {
      # Point Hermes at the local SearXNG instance for free web search
      SEARXNG_URL = "http://127.0.0.1:8888";
      
      # Git Bot Identity
      GIT_AUTHOR_NAME = "Hermes Bot";
      GIT_AUTHOR_EMAIL = "hermes@agent";
      GIT_COMMITTER_NAME = "Hermes Bot";
      GIT_COMMITTER_EMAIL = "hermes@agent";
    };
  };

  environment.localBinInPath = true;

  # ── Systemd Sandbox Escapes ─────────────────────────────────────────
  systemd.services.hermes-agent.serviceConfig = {
    # Mount external paths into the agent's sandboxed appdata directory.
    # The '-' prefix means systemd won't fail if the source path doesn't exist.
    BindPaths = [
      # Expose Nix daemon so Hermes can run `nix build` and execute code
      "-/nix/var/nix/daemon-socket/socket"
    ];
  };

  # Ensure the appdata directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata/hermes 2770 hermes users -"
    "d /mnt/local/appdata/hermes/workspace 2770 hermes users -"
  ];

  # Ensure the hermes user has POSIX permission to read/write files owned by the users group
  users.users.hermes.extraGroups = [ "users" ];
}
