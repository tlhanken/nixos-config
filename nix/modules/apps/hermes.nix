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
    stateDir = "/mnt/local/appdata/hermes";
    workingDirectory = "/mnt/local/appdata/hermes/workspace";

    # ── Secrets ────────────────────────────────────────────────────────
    # API keys (OPENROUTER_API_KEY, ANTHROPIC_API_KEY, etc.) are never
    # embedded in Nix — they live in the agenix-managed env file.
    # NOTE: To use Telegram, you must add TELEGRAM_BOT_TOKEN="<your_token>" to this secrets file.
    environmentFiles = [ config.age.secrets.ai-api-keys.path ];

    # ── Declarative Settings ───────────────────────────────────────────
    settings = {
      model = {
        default = "deepseek/deepseek-v4-flash-latest";
        provider = "openrouter";
        base_url = "https://openrouter.ai/api/v1";
        api_mode = "chat_completions";
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
      gateway = {
        enabled = true;
        platforms = {
          telegram = {
            enabled = true;
          };
        };
      };
      web = {
        enabled = true;
        port = 8642;
      };
      tts = {
        provider = "edge-tts";
        providers = {
          edge-tts = {
            voice = "en-US-AvaNeural";
          };
        };
      };
    };

    # ── Dependency Groups ──────────────────────────────────────────────
    extraDependencyGroups = [ "edge-tts" "voice" "messaging" "web" ];

    # ── Packages & Dependencies ────────────────────────────────────────
    # Inject tools directly into the agent's isolated PATH
    extraPackages = with pkgs; [
      searxng
      qmd
      git
      python3
      bash
      coreutils
      jq
      curl
      nix
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

  # Ensure the appdata directory and workspace subdirectories exist with correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/local/appdata/hermes 2770 hermes users -"
    "d /mnt/local/appdata/hermes/workspace 2770 hermes users -"
    "d /mnt/local/appdata/hermes/workspace/wiki 2770 hermes users -"
    "d /mnt/local/appdata/hermes/workspace/repos 2770 hermes users -"
    "d /mnt/local/appdata/hermes/workspace/tmp 2770 hermes users -"
    "d /mnt/local/appdata/hermes/workspace/shared 2770 hermes users -"
  ];

  # Ensure the hermes user has POSIX permission to read/write files owned by the users group
  users.users.hermes.extraGroups = [ "users" ];

  # ── Hermes Web Dashboard Service ────────────────────────────────────
  systemd.services.hermes-dashboard = {
    description = "Hermes Agent Web Dashboard";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default
      git
      bash
      coreutils
      nix
      searxng
      qmd
    ];
    environment = {
      HOME = "/mnt/local/appdata/hermes";
    };
    serviceConfig = {
      EnvironmentFile = config.age.secrets.ai-api-keys.path;
      ExecStart = "${inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/hermes dashboard --port 8643 --host 127.0.0.1 --no-open --skip-build";
      User = "hermes";
      Group = "users";
      WorkingDirectory = "/mnt/local/appdata/hermes";
      Restart = "always";
      RestartSec = 5;
    };
  };

  # ── Nginx Reverse Proxy for Hermes Web UI (Port 8642) ──────────────
  services.nginx.virtualHosts."hermes-dashboard" = {
    listen = [{ addr = "0.0.0.0"; port = 8642; ssl = false; }];
    locations."/" = {
      proxyPass = "http://127.0.0.1:8643";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host 127.0.0.1;
        proxy_set_header Origin http://127.0.0.1;
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 8642 ];

  # ── Git Repository Initialization for Hermes AppData ──────────────
  systemd.services.hermes-git-init = {
    description = "Initialize Git repository for Hermes AppData (SOUL, skills, memories, workspace)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "hermes";
      Group = "users";
      WorkingDirectory = "/mnt/local/appdata/hermes";
    };
    script = ''
      if [ ! -d .git ]; then
        ${pkgs.git}/bin/git init
        ${pkgs.git}/bin/git config user.name "Hermes Bot"
        ${pkgs.git}/bin/git config user.email "hermes@agent"
        
        cat <<'EOF' > .gitignore
.env
*.env
*.age
.hermes/audio_cache/
.hermes/image_cache/
.hermes/logs/
.hermes/state.db*
.hermes/.update_check
workspace/tmp/
workspace/shared/
workspace/repos/
EOF

        ${pkgs.git}/bin/git add .gitignore .hermes/SOUL.md .hermes/skills .hermes/memories .hermes/cron .hermes/hooks workspace 2>/dev/null || true
        ${pkgs.git}/bin/git commit -m "chore: initial hermes appdata snapshot (SOUL, skills, memories, workspace)" || true
      fi
    '';
  };

  # ── Pre-clone Repositories into Hermes Workspace ──────────────────
  systemd.services.hermes-repos-init = {
    description = "Pre-clone target repositories (nixos-config, tools, geoforge) into Hermes workspace repos";
    after = [ "network.target" "hermes-git-init.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "hermes";
      Group = "users";
      WorkingDirectory = "/mnt/local/appdata/hermes/workspace/repos";
    };
    script = ''
      REPOS=("nixos-config" "tools" "geoforge")
      for repo in "''${REPOS[@]}"; do
        TARGET="/mnt/local/appdata/hermes/workspace/repos/$repo"
        LOCAL_SRC="/home/tlhanken/workspace/$repo"
        REMOTE_URL="https://github.com/tlhanken/$repo.git"

        if [ ! -d "$TARGET/.git" ]; then
          echo "Initializing Hermes workspace repository for $repo..."
          if [ -d "$LOCAL_SRC/.git" ]; then
            ${pkgs.git}/bin/git clone "$LOCAL_SRC" "$TARGET"
            ${pkgs.git}/bin/git -C "$TARGET" remote set-url origin "$REMOTE_URL" 2>/dev/null || true
          else
            ${pkgs.git}/bin/git clone "$REMOTE_URL" "$TARGET" 2>/dev/null || true
          fi
          ${pkgs.git}/bin/git -C "$TARGET" config user.name "Hermes Bot" 2>/dev/null || true
          ${pkgs.git}/bin/git -C "$TARGET" config user.email "hermes@agent" 2>/dev/null || true
        fi
      done
    '';
  };

  # ── Hourly Git Auto-commit for Hermes Traceability ───────────────
  systemd.services.hermes-git-autocommit = {
    description = "Auto-commit Hermes AppData changes (skills, memories, workspace)";
    serviceConfig = {
      Type = "oneshot";
      User = "hermes";
      Group = "users";
      WorkingDirectory = "/mnt/local/appdata/hermes";
    };
    script = ''
      if [ -d .git ]; then
        ${pkgs.git}/bin/git add .gitignore .hermes/SOUL.md .hermes/skills .hermes/memories .hermes/cron .hermes/hooks workspace 2>/dev/null || true
        if ! ${pkgs.git}/bin/git diff --cached --quiet; then
          ${pkgs.git}/bin/git commit -m "auto: snapshot hermes appdata changes [$(date -Iseconds)]"
        fi
      fi
    '';
  };

  systemd.timers.hermes-git-autocommit = {
    description = "Hourly timer for Hermes AppData git auto-commit";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
