{ pkgs, inputs, lib, config, ... }:
let
  hermes-mod = import ./hermes-mod.nix pkgs;
  qmd = pkgs.callPackage ../../packages/qmd.nix { };
  scraplingSitePackages =
    "${config.home.homeDirectory}/.local/share/uv/tools/scrapling/lib/python3.12/site-packages";

  hermesAgent = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    extraDependencyGroups = [ "edge-tts" "voice" "messaging" "web" ];
  };

  pkgsPatched = pkgs.extend (self: super: {
    fetchurl = args:
      if (builtins.isAttrs args && lib.hasInfix "headers.tar.gz" (args.url or ""))
      then super.fetchurl (args // { sha256 = "sha256-0nUJBQDEikyYntZwq+ycH32mzEQtQmz3ICz9eeTMpJk="; })
      else super.fetchurl args;
  });

  hermesDesktop = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.desktop.override {
    pkgs = pkgsPatched;
  };

  hermesDesktopItem = pkgs.makeDesktopItem {
    name = "hermes";
    desktopName = "Hermes AI";
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
    searxng
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
    PYTHONPATH = scraplingSitePackages;
    SEARXNG_URL = "http://127.0.0.1:8888";
    # Makes ctypes.util.find_library discover profile-installed shared libs
    # (e.g. libportaudio.so) via ld's -L search.
    LD_LIBRARY_PATH = "/etc/profiles/per-user/${config.home.username}/lib";
  };

  home.activation.installScrapling = lib.hm.dag.entryAfter ["writeBoundary"] ''
    UV_PYTHON=${pkgs.python312}/bin/python3 \
    UV_PYTHON_DOWNLOADS=never \
      ${pkgs.uv}/bin/uv tool install 'scrapling[ai]' --quiet
  '';

  programs.bash.initExtra = ''
    if [ -f /run/agenix/ai-api-keys ]; then
      set -a; source /run/agenix/ai-api-keys; set +a
    fi
  '';
}
