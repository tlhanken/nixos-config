{ pkgs, inputs, lib, ... }:
let
  hermes-mod = pkgs.buildNpmPackage rec {
    pname = "hermes-mod";
    version = "0.2.0";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/hermes-mod/-/hermes-mod-${version}.tgz";
      hash = "sha256-tWWTV061tOAjkiFYifKAlNbaP3pAxuSuaPrcpstXpos=";
    };
    postPatch = ''
      cp ${./hermes-mod-package-lock.json} package-lock.json
    '';
    npmDepsHash = "sha256-2cES2+/5AatsbfdxeCeEzkFzl+UAl0lnOt15aSLv9Ds=";
    dontNpmBuild = true;
  };
in
{
  home.packages = with pkgs; [
    (inputs.hermes-agent.packages.${pkgs.system}.default.override {
      extraPythonPackages = with pkgs.python312Packages; [
        sounddevice
        numpy
      ];
    })
    searxng
    hermes-mod
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Point playwright (used by scrapling's DynamicFetcher) at the Nix-managed
  # Chromium so it never tries to download browsers at runtime.
  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    # Scrapling lives in a uv tool venv (installed by home.activation below).
    # Prepend its site-packages so the Nix-managed hermes Python can find it.
    PYTHONPATH = "/home/tlhanken/.local/share/uv/tools/scrapling/lib/python3.12/site-packages";
    # Point Hermes at the local SearXNG instance for free web search.
    SEARXNG_URL = "http://127.0.0.1:8888";
  };

  # Install scrapling (and its Python deps) as a uv tool. Runs idempotently on
  # every home-manager switch — uv skips the install if already up to date.
  # UV_PYTHON_DOWNLOADS=never forces uv to use the Nix-managed Python instead
  # of downloading a generic Linux binary (which NixOS can't run without nix-ld).
  home.activation.installScrapling = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    UV_PYTHON=${pkgs.python312}/bin/python3 \
    UV_PYTHON_DOWNLOADS=never \
      ${pkgs.uv}/bin/uv tool install 'scrapling[ai]' --quiet
  '';

  # Source AI provider API keys into the shell so hermes and other tools can find them.
  # The file is decrypted by agenix at boot and lives at /run/agenix/ai-api-keys.
  programs.bash.initExtra = ''
    if [ -f /run/agenix/ai-api-keys ]; then
      set -a; source /run/agenix/ai-api-keys; set +a
    fi
  '';
}
