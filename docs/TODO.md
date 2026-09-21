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

## God's Eye View (`well-of-mimir-2`)

- [ ] Add optional API keys for extended intelligence tools:
  - `just edit-secret gods-eye-view-secrets` (alias `just es gods-eye-view-secrets`)
  - Variables to add when keys are acquired:
    - `GOOGLE_MAPS_API_KEY`: Photorealistic 3D Earth globe tiles
    - `CESIUM_ION_TOKEN`: High-resolution terrain, 3D buildings, and imagery
    - `OPENAI_API_KEY`: Real-time voice interaction via microphone button in dock
    - `AISSTREAM_API_KEY`: Live global maritime vessel & ship tracking
    - `OPENSKY_CLIENT_ID` / `OPENSKY_CLIENT_SECRET`: Real-time aircraft ADS-B tracking
  - Rekey secrets: `just rekey-secrets` (alias `just rs`)
  - Deploy update: `just remote-switch well-of-mimir-2`
- [ ] Upstream updates: Run `just update-gods-eye-view` (alias `just ugev`) to check GitHub, compute new SRI and npm dependency hashes, and update [gods-eye-view.nix](file:///home/tlhanken/workspace/nixos-config/nix/modules/apps/gods-eye-view.nix).
