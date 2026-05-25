{ pkgs, inputs, config, ... }: {
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    # ── Container Mode ─────────────────────────────────────────────────
    container = {
      enable = true;
      hostUsers = [ "tlhanken" ];
      # Mount your workspace into the container so the agent can read/write it
      extraVolumes = [
        "/home/tlhanken/workspace:/workspace:rw"
      ];
    };

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
        # Tell the agent to default to the mounted workspace folder
        cwd = "/workspace";
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
  };

  environment.localBinInPath = true;

  # Install scrapling into the container on every service start.
  # pip is idempotent so this is a fast no-op after the first run.
  # The container's writable layer keeps it installed across restarts.
  systemd.services.hermes-agent.serviceConfig.ExecStartPost =
    pkgs.writeShellScript "hermes-install-scrapling" ''
      # Wait until the container is responsive (up to 30s)
      for i in $(seq 1 30); do
        ${pkgs.docker}/bin/docker exec hermes-agent true 2>/dev/null && break
        sleep 1
      done
      ${pkgs.docker}/bin/docker exec hermes-agent \
        pip install 'scrapling[ai]' --quiet || true
    '';
}
