# Configuration backlog

Tracked improvements not yet implemented.

## Security (circle back)

- [ ] Move `hashedPassword` values from host `configuration.nix` into agenix secrets
- [ ] Move SSH `authorizedKeys` from plaintext config into agenix (root and user keys)

## AI stack on sleipnir (re-enable when ready)

- [ ] `inputs.self.modules.apps.ollama` (models → `/mnt/ai/models/llm` via `my.mounts.ai`)
- [ ] `inputs.self.modules.apps.open-webui`
- [x] `inputs.self.modules.apps.comfyui` on sleipnir (requires `nix-comfyui` input)
- [x] `my.mounts.ai` — `/mnt/ai` shared store (galar local, sleipnir NFS)

## Hermes (sleipnir / `profile-hermes`)

- [ ] Verify Hermes voice mode end-to-end — `extraDependencyGroups = [ "edge-tts" "voice" ]`, `portaudio`, and `LD_LIBRARY_PATH` to the HM profile lib dir (workaround for Python 3.13+ `find_library` not using ldconfig)
- [ ] Re-enable `hermesDesktop` in `profile-hermes.nix` once upstream nixpkgs fixes the Electron 43.4.1 node headers hash mismatch (`node-v43.4.1-headers.tar.gz`)

## Claude Desktop

- [ ] Re-enable `claude-desktop.nix` in `profile-productivity.nix` once `claude-desktop-debian` builds cleanly again (patch step / `addTrustedFolder` failures in recent versions)

## Packaging

- [x] Promote `nix/modules/home/hermes-mod.nix` to a flake `packages.*.hermes-mod` output (moved to `nix/packages/hermes-mod.nix`)
