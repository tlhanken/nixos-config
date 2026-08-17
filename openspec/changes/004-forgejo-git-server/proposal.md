# OpenSpec Change Proposal: 004-forgejo-git-server

## Summary
Add **Forgejo** as the fleet's self-hosted Git server on host `well-of-mimir-2`, configure persistent state on local appdata storage, open required network ports, and register Forgejo in the `homepage` fleet dashboard.

## Motivation
1. **Self-Hosted Code Hosting**: Provides a lightweight, GitHub-compatible Git hosting platform on the local network (`well-of-mimir-2`), enabling local repository mirrors, private code backups, and automated CI runner integrations.
2. **Low Overhead**: Forgejo runs as a compiled Go binary with an embedded SQLite database backend, taking ~50–100MB RAM without requiring complex container or multi-service databases.
3. **Fleet Dashboard Visibility**: Adding Forgejo to `homepage.nix` gives users quick access to the git web interface directly from the fleet portal dashboard.

## Proposed Changes
- **Forgejo App Module (`nix/modules/apps/forgejo.nix`)**:
  - Configure `services.forgejo` with `HTTP_PORT = 3000`, `SSH_PORT = 2222`, `stateDir = "/mnt/local/appdata/forgejo"`.
  - Open firewall TCP ports 3000 and 2222.
  - Set tmpfiles permissions for `/mnt/local/appdata/forgejo`.
- **Homepage Module (`nix/modules/apps/homepage.nix`)**:
  - Add "Forgejo" service item under "Tools" linking to `http://${well-of-mimir-2.magicDns}:3000`.
- **Host Configuration (`nix/hosts/well-of-mimir-2/configuration.nix`)**:
  - Import `inputs.self.modules.apps.forgejo` in module imports.
- **Domain Specification (`openspec/specs/apps-and-services.md`)**:
  - Document Forgejo service capability and contracts.

## Verification Plan
- Run `just check` (`nix flake check`) to ensure Nix flake evaluation passes cleanly across all hosts.
- Verify `well-of-mimir-2` top-level system evaluation.
