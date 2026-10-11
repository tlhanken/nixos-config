# Tasks: 008-firecrawl-integration

- [x] 1. Create Firecrawl application module (`nix/modules/apps/firecrawl.nix`) <!-- id: 1 -->
  - [x] 1.1 Declare docker-compose stack configuration for Firecrawl microservices (api, playwright, redis, rabbitmq, nuq-postgres) <!-- id: 1.1 -->
  - [x] 1.2 Configure systemd unit `firecrawl.service` with start/stop lifecycle <!-- id: 1.2 -->
  - [x] 1.3 Configure storage directory tmpfiles rules under `/mnt/local/appdata/firecrawl` <!-- id: 1.3 -->
  - [x] 1.4 Open firewall TCP port 3002 <!-- id: 1.4 -->

- [x] 2. Update Hermes Agent configuration (`nix/modules/apps/hermes.nix`) <!-- id: 2 -->
  - [x] 2.1 Add `FIRECRAWL_API_URL` to hermes-agent and hermes-dashboard service environments <!-- id: 2.1 -->
  - [x] 2.2 Add `firecrawl` to `extraDependencyGroups` <!-- id: 2.2 -->
  - [x] 2.3 Configure `extract_backend = "firecrawl"` and `search_backend = "firecrawl"` in settings <!-- id: 2.3 -->
  - [x] 2.4 Update toolsets to include `terminal`, `file`, and `web` <!-- id: 2.4 -->
  - [x] 2.5 Configure Sleipnir Home Manager profile (`profile-hermes.nix`) with Firecrawl URL over Tailscale and `firecrawl` dependency group <!-- id: 2.5 -->

- [x] 3. Enable Firecrawl on host `well-of-mimir-2` (`nix/hosts/well-of-mimir-2/configuration.nix`) <!-- id: 3 -->
  - [x] 3.1 Import `inputs.self.modules.apps.firecrawl` <!-- id: 3.1 -->

- [x] 4. Register Firecrawl on Homepage dashboard (`nix/modules/apps/homepage.nix`) <!-- id: 4 -->
  - [x] 4.1 Add Firecrawl card to dashboard under Tools next to SearXNG <!-- id: 4.1 -->

- [x] 5. Update domain specification (`openspec/specs/apps-and-services.md`) <!-- id: 5 -->
  - [x] 5.1 Document Firecrawl contract, capability, and host placement invariants <!-- id: 5.1 -->

- [x] 6. Validation and Flake Check <!-- id: 6 -->
  - [x] 6.1 Validate Nix flake evaluation with `nix flake check` <!-- id: 6.1 -->

- [x] 7. Decommission SearXNG in favor of Firecrawl <!-- id: 7 -->
  - [x] 7.1 Remove SearXNG module and imports from sleipnir and well-of-mimir-2 <!-- id: 7.1 -->
  - [x] 7.2 Remove SearXNG package and SEARXNG_URL environment variable from Hermes NixOS & HM profiles <!-- id: 7.2 -->
  - [x] 7.3 Remove SearXNG card from Homepage dashboard <!-- id: 7.3 -->
  - [x] 7.4 Remove SEARXNG_ENDPOINT from Firecrawl Docker environment <!-- id: 7.4 -->
