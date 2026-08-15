# Tasks: 002-hermes-web-telegram-desktop

- [x] Enable Web Portal and Telegram Gateway settings in `nix/modules/apps/hermes.nix`
- [x] Add `messaging` and `web` to `extraDependencyGroups` in `nix/modules/apps/hermes.nix`
- [x] Add `inputs.hermes-agent.packages.${system}.desktop` package to `nix/modules/home/profile-hermes.nix`
- [x] Update domain specifications `apps-and-services.md` and `home-manager-profiles.md`
- [x] Validate changes cleanly with `nix flake check`
