# OpenSpec Change Proposal: 007-gods-eye-view

## Summary
Add **God's Eye View** (`bilawalsidhu/gods-eye-view`) as the fleet's real-time 3D Earth spatial intelligence console on host `well-of-mimir-2`, packaged purely via Nix with locked Node.js 24 dependencies, reverse-proxied over Tailscale with WebSocket support, integrated into the Homepage dashboard, and wired to an optional dedicated agenix secret file.

## Motivation
1. **Real-Time Spatial Intelligence**: Provides an explorable 3D Earth console in the browser tracking live aircraft (ADS-B), maritime vessels (AIS), orbital satellites (CelesTrak), weather (Open-Meteo), earthquakes (USGS), and public CCTV.
2. **Stateless Architecture & Zero Snapshot Churn**: God's Eye View holds no persistent user databases or uploads. Packaging the application into `/nix/store` (`com.sun:auto-snapshot = false`) and using a RAM tmpfs for runtime (`/run/gods-eye-view`) prevents snapshot bloat on `/mnt/local/appdata` and `/var`.
3. **Pure Nix Reproducibility**: Building the package with `buildNpmPackage` and locked `npmDepsHash` eliminates runtime network dependencies (`git clone`, `npm ci`) and guarantees deterministic, offline-capable boots.
4. **Tailscale Ingress & Dashboard Visibility**: Placing the service behind Nginx on port `4173` preserves upstream localhost security assumptions while cleanly terminating Tailscale traffic, and surfaces the console directly in Homepage under Tools.

## Proposed Changes
- **God's Eye View Module (`nix/modules/apps/gods-eye-view.nix`)**:
  - Build package via `buildNpmPackage` using `nodejs_24`, pinned source commit, and locked npm dependencies.
  - Set up hardened systemd unit under unprivileged `gods-eye-view` user with `ProtectSystem = "strict"`, `ProtectHome = true`, and `RuntimeDirectory = "gods-eye-view"`.
  - Configure Nginx virtual host on port `4173` with WebSocket proxying to `127.0.0.1:4173`.
  - Wire conditional `EnvironmentFile` from agenix secrets.
  - Open firewall TCP port `4173`.
- **Secrets Management (`nix/modules/secrets/`)**:
  - Register `"encrypted/gods-eye-view-secrets.age".publicKeys = all;` in `secrets.nix`.
  - Register `gods-eye-view-secrets` conditionally in `mod.nix`.
- **Host Configuration (`nix/hosts/well-of-mimir-2/configuration.nix`)**:
  - Import `inputs.self.modules.apps.gods-eye-view`.
- **Homepage Module (`nix/modules/apps/homepage.nix`)**:
  - Add "God's Eye View" service card under "Tools" linking to `http://${well-of-mimir-2.magicDns}:4173` with icon `mdi-earth`.
- **Domain Specification (`openspec/specs/apps-and-services.md`)**:
  - Document God's Eye View capability, contracts, and placement rules.

## Verification Plan
- Run `nix flake check` (`just check`) to ensure 100% clean evaluation across all fleet targets.
- Verify `well-of-mimir-2` top-level system derivation evaluation.
