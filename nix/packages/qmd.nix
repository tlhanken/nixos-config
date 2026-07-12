{ pkgs, ... }: pkgs.buildNpmPackage rec {
  pname = "qmd";
  version = "2.5.3";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@tobilu/qmd/-/qmd-${version}.tgz";
    hash = "sha512-wUKc4pSPDbgs7mV7JYE8/Qj1pNXXatJFV8byTT/T3yLaoAXheFtWu0BgSWwoWGhRkMmxl5Qyitt66NHgbMyeBA==";
  };

  postPatch = ''
    cp ${./qmd-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-vGN9KT2KPkS5xidL3lT95kx2488nFpFReGs7n4s1LUU=";

  nativeBuildInputs = with pkgs; [
    python3
    node-gyp
    gcc
    gnumake
    pkg-config
  ];

  dontNpmBuild = true;

  meta = {
    description = "On-device hybrid search for markdown files with BM25, vector search, and LLM reranking";
    homepage = "https://github.com/tobi/qmd";
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.linux;
  };
}
