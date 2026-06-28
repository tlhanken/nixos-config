{ pkgs, lib }: pkgs.buildNpmPackage rec {
  pname = "openspec";
  version = "1.4.1";

  # Fetch the scoped npm tarball directly.
  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@fission-ai/openspec/-/openspec-${version}.tgz";
    hash = "sha512-C/NQsybgjqtSr29QAv4NbO1bZTgozu8GAUSiONthenZ5W4TQ2bvyj8LVmr76qb90iGeTLEFkcdnI+iYYaFLKyA==";
  };

  # The tarball ships its own package.json (with devDeps) but no lock file.
  # We inject our lock file (runtime deps only) and strip devDependencies +
  # the postinstall script so npm ci doesn't try to fetch dev packages.
  postPatch = ''
    cp ${./openspec-package-lock.json} package-lock.json
    # Remove devDependencies and scripts that reference them
    ${pkgs.nodejs}/bin/node -e "
      const fs = require('fs');
      const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
      delete pkg.devDependencies;
      delete pkg.scripts.postinstall;
      delete pkg.scripts.release;
      delete pkg.scripts.changeset;
      fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    "
  '';

  npmDepsHash = "sha256-kc3sh4V2SNY/7q9G/dGkPYhv8LM00sSJk8GPGs0Ftt8=";

  npmFlags = [ "--ignore-scripts" ];

  dontNpmBuild = true;
}
