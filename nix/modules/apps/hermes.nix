{ pkgs, inputs, config, ... }: {
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    # ── Secrets ────────────────────────────────────────────────────────
    # API keys (OPENROUTER_API_KEY, ANTHROPIC_API_KEY, etc.) are never
    # embedded in Nix — they live in the agenix-managed env file.
    environmentFiles = [ config.age.secrets.ai-api-keys.path ];

    # ── Declarative Settings ───────────────────────────────────────────
    settings = {
      model = {
        default = "anthropic/claude-3-5-haiku";
      };
      toolsets = [ "all" ];
      terminal = {
        # Actual host workspace path (not a container mount)
        cwd = "/home/tlhanken/workspace";
      };
    };

    # ── Packages & Dependencies ────────────────────────────────────────
    # Inject tools directly into the agent's isolated PATH
    extraPackages = with pkgs; [
      searxng
    ];

    extraPythonPackages = with pkgs.python312Packages; [
      sounddevice
      numpy
    ];

    # ── Scrapling ──────────────────────────────────────────────────────
    # Scrapling is not in nixpkgs so it lives in a uv tool venv managed
    # by home-manager's activation script in profile-hermes.nix.
    # The hermes wrapper uses ${PYTHONPATH:+...} — it prepends to whatever
    # PYTHONPATH is already set — so setting it here causes scrapling's
    # site-packages to be visible to the agent's Python at runtime.
    # UV_PYTHON is pinned to python312 in profile-hermes.nix so the paths align.
    environment = {
      PYTHONPATH = "/home/tlhanken/.local/share/uv/tools/scrapling/lib/python3.12/site-packages";
      # Point Hermes at the local SearXNG instance for free web search
      SEARXNG_URL = "http://127.0.0.1:8888";
    };
  };

  environment.localBinInPath = true;
}
