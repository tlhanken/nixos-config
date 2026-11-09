{ pkgs, lib ? pkgs.lib, ... }:
pkgs.buildNpmPackage rec {
  pname = "openrig";
  version = "0.7.10";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@openrig/cli/-/cli-${version}.tgz";
    hash = "sha256-xVr/fnx9FCnm0S7olUCWEAW8se/W5wF3UwcRVbGVJzI=";
  };

  postPatch = ''
    cp ${./openrig-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-JEDeqf4CHbSiXZTgMCi8mPs6MdSdgf0wcsYX9VUAnws=";

  dontNpmBuild = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/rig \
      --prefix PATH : ${lib.makeBinPath [ pkgs.tmux pkgs.git pkgs.openssh ]}
    wrapProgram $out/bin/openrig-tui \
      --prefix PATH : ${lib.makeBinPath [ pkgs.tmux pkgs.git pkgs.openssh ]}
  '';

  meta = with lib; {
    description = "Multi-agent coordination harness and control plane for AI coding agents";
    homepage = "https://openrig.dev";
    license = licenses.asl20;
    mainProgram = "rig";
    platforms = platforms.linux;
  };
}
