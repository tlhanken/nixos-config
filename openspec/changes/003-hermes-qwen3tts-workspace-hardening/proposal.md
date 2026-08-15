# OpenSpec Change Proposal: 003-hermes-edgetts-workspace-hardening

## Summary
Configure declarative **Edge-TTS** provider settings in Hermes Agent, expand Hermes' execution toolset with standard scripting runtimes (`python3`, `bash`, `coreutils`, `jq`, `curl`, `nix`), and establish structured workspace directory boundaries (`wiki`, `repos`, `tmp`, `shared`) with Git exclusion rules for scratch space, temporary audio/downloads, and nested git repositories.

## Motivation
1. **Zero-Maintenance TTS**: Using Edge-TTS as the default provider eliminates out-of-band PyTorch/Python venv overhead and CPU/GPU memory footprint on `well-of-mimir-2`, while allowing Hermes to dynamically download/run local models (like Qwen3-TTS) on demand via Python scripts.
2. **Scripting Autonomy**: Hermes requires Python, Bash, Coreutils, and Nix binaries in its PATH to run workspace scripts, draft MRs, and evaluate Nix configurations (`just check`) without elevated root privileges.
3. **Clean Workspace & Storage Boundaries**: Hermes' appdata repository needs explicit directory exclusion rules (`workspace/tmp/`, `workspace/shared/`, `workspace/repos/`) to prevent intermediate audio files, temporary downloads, Nextcloud sync data, or nested `.git` submodules from cluttering Git history, while keeping LLM Wiki entries tracked.

## Proposed Changes
- **Hermes App Module (`nix/modules/apps/hermes.nix`)**:
  - Configure `services.hermes-agent.settings.tts` with default `edge-tts` provider (`voice = "en-US-AvaNeural"`).
  - Add `python3`, `bash`, `coreutils`, `jq`, `curl`, `nix` to `extraPackages`.
  - Update `tmpfiles.rules` and `.gitignore` template for `workspace/tmp`, `workspace/shared`, and `workspace/repos`.
  - Add `hermes-repos-init` systemd oneshot service to pre-clone `nixos-config`, `tools`, and `geoforge` into `workspace/repos/`.

## Verification Plan
- Run `nix flake check` to ensure all NixOS configurations evaluate cleanly.
- Run `nix build .#nixosConfigurations.well-of-mimir-2.config.system.build.toplevel`.
