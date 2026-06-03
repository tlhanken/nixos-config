pkgs: pkgs.buildNpmPackage rec {
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
}
