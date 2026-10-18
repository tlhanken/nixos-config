{ pkgs, inputs, lib, config, ... }:
let
  net = import ../../lib/network.nix;
  hermes-mod = pkgs.callPackage ../../packages/hermes-mod.nix { };
  qmd = inputs.qmd.packages.${pkgs.stdenv.hostPlatform.system}.default;
  hermesAgent = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    extraDependencyGroups = [ "edge-tts" "voice" "messaging" "web" "firecrawl" ];
    # Sleipnir consumes the Hermes package directly rather than through
    # services.hermes-agent, so inputs.muninn.nixosModules.default cannot reach it and
    # the package has to be attached here by hand. Same effect: the package's
    # site-packages joins Hermes' PYTHONPATH, which is what makes the
    # hermes_agent.memory_providers entry point discoverable.
    extraPythonPackages = [ inputs.muninn.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  };

  hermesDesktop = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.desktop;

  hermesDesktopItem = pkgs.makeDesktopItem {
    name = "hermes-cli";
    desktopName = "Hermes AI (CLI)";
    genericName = "AI Assistant";
    exec = "${hermesAgent}/bin/hermes";
    icon = "utilities-terminal";
    comment = "Autonomous AI Agent with voice, web search, and code execution";
    categories = [ "Utility" "Development" "System" ];
    keywords = [ "AI" "Hermes" "Assistant" "LLM" "CLI" "Agent" ];
    terminal = true;
  };
in {
  home.packages = with pkgs; [
    hermesAgent
    hermesDesktop
    hermesDesktopItem
    hermes-mod
    qmd
    # PortAudio — required by sounddevice (Hermes voice mode). find_library
    # doesn't use ldconfig on Linux Python 3.13+; LD_LIBRARY_PATH makes ld
    # find profile-installed libs like libportaudio.so.
    portaudio
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    FIRECRAWL_API_URL = "http://${net.hosts.well-of-mimir-2.magicDns}:3002";
    FIRECRAWL_API_KEY = "self-hosted";
    # Makes ctypes.util.find_library discover profile-installed shared libs
    # (e.g. libportaudio.so) via ld's -L search.
    LD_LIBRARY_PATH = "/etc/profiles/per-user/${config.home.username}/lib";
  };

  programs.bash.initExtra = ''
    if [ -f /run/agenix/ai-api-keys ]; then
      set -a; source /run/agenix/ai-api-keys; set +a
    fi
  '';
}
