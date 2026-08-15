# OpenSpec Change Proposal: 002-hermes-web-telegram-desktop

## Summary
Enable Hermes Agent Web Portal and Telegram Messaging Gateway in `nix/modules/apps/hermes.nix`, and integrate the native Electron `hermes-desktop` GUI application package into `nix/modules/home/profile-hermes.nix`.

## Motivation
Hermes Agent provides multi-platform gateway capabilities (Telegram, Discord, Slack) and an interactive web portal for chat & workspace monitoring. Enabling these features in the NixOS app module allows remote interaction over Telegram and web browser, while adding `hermes-desktop` to `profile-hermes` gives local workstation users the native desktop interface.

## Proposed Changes
- **NixOS App Module (`nix/modules/apps/hermes.nix`)**:
  - Add `extraDependencyGroups = [ "edge-tts" "voice" "messaging" "web" ];` to `services.hermes-agent`.
  - Add `gateway.enabled = true`, `gateway.platforms.telegram.enabled = true`, and `web.enabled = true` to `services.hermes-agent.settings`.
- **Home Manager Profile (`nix/modules/home/profile-hermes.nix`)**:
  - Add `inputs.hermes-agent.packages.${system}.desktop` to `home.packages`.
  - Update `hermesAgent` package override with `"messaging"` and `"web"` dependency groups.
- **Domain Specifications (`openspec/specs/`)**:
  - Update `apps-and-services.md` and `home-manager-profiles.md` with updated contracts.

## Verification Plan
- Run `nix flake check` to ensure all NixOS configurations and Home Manager profiles build and evaluate cleanly.
