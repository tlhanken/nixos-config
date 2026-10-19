{ pkgs, inputs, lib, config, ... }:
let
  net = import ../../lib/network.nix;
  hermes-mod = pkgs.callPackage ../../packages/hermes-mod.nix { };
  qmd = inputs.qmd.packages.${pkgs.stdenv.hostPlatform.system}.default;
  hermesDesktopItem = pkgs.makeDesktopItem {
    name = "hermes-cli";
    desktopName = "Hermes AI (CLI)";
    genericName = "AI Assistant";
    exec = "${config.programs.hermes-agent.package}/bin/hermes";
    icon = "utilities-terminal";
    comment = "Autonomous AI Agent with voice, web search, and code execution";
    categories = [ "Utility" "Development" "System" ];
    keywords = [ "AI" "Hermes" "Assistant" "LLM" "CLI" "Agent" ];
    terminal = true;
  };
in {
  imports = [
    inputs.hermes-agent.homeManagerModules.default
    # Muninn: wires the package into services.hermes-agent.extraPythonPackages
    # and sets services.hermes-agent.settings.memory.provider = "muninn"
    inputs.muninn.homeManagerModules.default
  ];

  programs.hermes-agent = {
    enable = true;
    desktop.enable = true;
  };

  services.hermes-agent = {
    enable = true;
    extraDependencyGroups = [ "edge-tts" "voice" "messaging" "web" "firecrawl" ];
  };

  home.packages = with pkgs; [
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
