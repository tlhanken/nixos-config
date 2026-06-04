# Configuration backlog

Tracked improvements not yet implemented.

## Security (circle back)

- [ ] Move `hashedPassword` values from host `configuration.nix` into agenix secrets
- [ ] Move SSH `authorizedKeys` from plaintext config into agenix (root and user keys)

## AI stack on sleipnir (re-enable when ready)

- [ ] `inputs.self.modules.apps.ollama`
- [ ] `inputs.self.modules.apps.open-webui`
- [ ] `inputs.self.modules.apps.comfyui` (requires `nix-comfyui` input)

## Hermes (sleipnir / `profile-hermes`)

- [ ] Add sound support for hermes-agent — `sounddevice` was dropped from `extraPythonPackages` because it pulls `cffi`, which collides with hermes’ sealed venv; find a supported approach (upstream fix, different audio dep, or runtime install outside the override)

## Claude Desktop

- [ ] Re-enable `claude-desktop.nix` in `profile-productivity.nix` once `claude-desktop-debian` builds cleanly again (patch step / `addTrustedFolder` failures in recent versions)

## Packaging

- [ ] Promote `nix/modules/home/hermes-mod.nix` to a flake `packages.*.hermes-mod` output when convenient
