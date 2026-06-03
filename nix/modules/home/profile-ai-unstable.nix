# Unstable nixpkgs with allowUnfree for AI/dev tools not yet on stable.
{ inputs, lib, system }:
import inputs.nixpkgs-unstable {
  inherit system;
  config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "antigravity"
      "claude-code"
      "code"
      "cursor"
      "lmstudio"
      "vscode"
    ];
}
