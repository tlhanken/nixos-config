# OpenSpec Change Proposal: 008-firecrawl-integration

## Summary
Add **Firecrawl** (`mendableai/firecrawl`) as the fleet's self-hosted web scraping, crawling, and content extraction engine on host `well-of-mimir-2`. Deploy Firecrawl via a declarative Docker Compose stack managed by systemd, expose its API on port `3002`, register it on the Homepage dashboard, and configure the Hermes Agent on `well-of-mimir-2` with `FIRECRAWL_API_URL`, the `firecrawl` dependency group, and updated toolset declarations (`web_extract` / `web_search`) for autonomous web extraction.

## Motivation
1. **High-Fidelity Web Extraction for AI Agents**: While SearXNG provides privacy-preserving search queries, AI agents need the ability to scrape JavaScript-heavy single-page applications, documentation sites, and articles into clean, LLM-ready markdown. Firecrawl provides this with its headless Playwright/Chromium engine.
2. **Local Loopback Integration for Hermes**: Hermes Agent running on `well-of-mimir-2` ("well") has native support for Firecrawl (`plugins/web/firecrawl`). Configuring Firecrawl on `well-of-mimir-2` allows Hermes to access the service with minimal latency via loopback (`http://127.0.0.1:3002`) without cloud rate limits or token costs.
3. **Reproducible Multi-Container Orchestration**: Firecrawl consists of five tightly coupled microservices (`api`, `playwright-service`, `redis`, `rabbitmq`, `nuq-postgres`). Orchestrating this via a declarative Compose specification managed by a systemd unit (`firecrawl.service`) guarantees automatic startup, proper dependency ordering, and network isolation.
4. **Persistent State & Clean Placement**: Consistent with the NAS/AI application standard on `well-of-mimir-2`, persistent state for Postgres, Redis, and RabbitMQ lives under `/mnt/local/appdata/firecrawl`.
5. **Fleet Visibility**: Exposing port `3002` over Tailscale allows developers to access the API directly from workstations (e.g. `sleipnir`) and provides a service card on the central Homepage dashboard.

## Proposed Changes

### 1. Firecrawl NixOS Module (`nix/modules/apps/firecrawl.nix`)
- Define `systemd.services.firecrawl` running `docker compose` with a declarative Compose YAML file.
- Configure microservices:
  - `api`: `ghcr.io/firecrawl/firecrawl:latest` listening on host port `3002`.
  - `playwright-service`: `ghcr.io/firecrawl/playwright-service:latest` running headless Chromium with media blocking and concurrency limits.
  - `redis`: `redis:alpine` for caching and job state.
  - `rabbitmq`: `rabbitmq:3-management` for crawl queue messaging.
  - `nuq-postgres`: `ghcr.io/firecrawl/nuq-postgres:latest` for queue database.
- Wire local SearXNG endpoint (`http://host.docker.internal:8888`) and Ollama endpoint (`http://host.docker.internal:11434`) via `extra_hosts`.
- Configure `systemd.tmpfiles.rules` for `/mnt/local/appdata/firecrawl` and data subdirectories.
- Allow TCP port `3002` in `networking.firewall.allowedTCPPorts`.

### 2. Hermes Integration (`nix/modules/apps/hermes.nix`)
- Inject `FIRECRAWL_API_URL = "http://127.0.0.1:3002"` into `services.hermes-agent.environment` and `systemd.services.hermes-dashboard.environment`.
- Add `"firecrawl"` to `extraDependencyGroups` to ensure `firecrawl-py` is installed in Hermes's Python environment.
- Add `extract_backend = "firecrawl"` and `search_backend = "firecrawl"` to `settings.web`.
- Update `settings.toolsets` to include `[ "terminal" "file" "web" ]` ensuring `web_search` and `web_extract` tools are actively enabled.

### 3. Host Configuration (`nix/hosts/well-of-mimir-2/configuration.nix`)
- Import `inputs.self.modules.apps.firecrawl`.

### 4. Fleet Dashboard (`nix/modules/apps/homepage.nix`)
- Register Firecrawl under "AI" or "Tools" pointing to `http://${well-of-mimir-2.magicDns}:3002`.

### 5. Domain Specification (`openspec/specs/apps-and-services.md`)
- Document Firecrawl capability, contracts, and placement rules under server services.

## Verification Plan
- Run `nix flake check` to ensure 100% clean evaluation across all fleet targets.
- Verify `well-of-mimir-2` NixOS configuration evaluation.
