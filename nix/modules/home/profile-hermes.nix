{ pkgs, inputs, lib, config, ... }:
let
  hermes-mod = import ./hermes-mod.nix pkgs;
  scraplingSitePackages =
    "${config.home.homeDirectory}/.local/share/uv/tools/scrapling/lib/python3.12/site-packages";
in {
  home.packages = with pkgs; [
    (inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      extraDependencyGroups = [ "edge-tts" "voice" ];
    })
    searxng
    hermes-mod
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
