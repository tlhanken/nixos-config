{ pkgs, inputs, lib, config, ... }:
let
  hermes-mod = import ./hermes-mod.nix pkgs;
  scraplingSitePackages =
    "${config.home.homeDirectory}/.local/share/uv/tools/scrapling/lib/python3.12/site-packages";
in {
  home.packages = with pkgs; [
    # sounddevice pulls cffi, which collides with hermes' sealed venv — use numpy only
    (inputs.hermes-agent.packages.${pkgs.system}.default.override {
      extraPythonPackages = with pkgs.python312Packages; [numpy];
    })
    searxng
    hermes-mod
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PYTHONPATH = scraplingSitePackages;
    SEARXNG_URL = "http://127.0.0.1:8888";
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
