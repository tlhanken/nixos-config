# OpenSpec Specification: Applications & Server Services

## Intent & Objectives
Establish capability standards, modular option contracts, and placement rules for fleet application services, ensuring services are isolated, securely reverse-proxied, and assigned to appropriate hosts.

## Workload Placement Invariants
- **High-Compute & AI Services**: **MUST** be deployed on host `well-of-mimir-2`.
- **Media Streaming**: **MUST** be deployed on host `galar`.
- **Local Desktop Applications**: **MUST** be packaged for workstation `sleipnir`.
- **Central Portal & Reverse Proxy**: **MUST** run on `well-of-mimir-2` to unify service ingress over Tailscale.

## Service Capabilities & Contracts

### 1. Autonomous AI Agent (`hermes.nix`)
- **Capability**: Provides a sandboxed environment for autonomous AI task execution, multi-platform messaging gateways, and interactive web interface.
- **Contract**:
  - State and agent workspaces **MUST** reside on persistent storage exported via NFS to allow remote editing from developer workstations.
  - **MUST** enable the Web Portal (`settings.web.enabled = true`) on port `8642`.
  - **MUST** enable the Telegram messaging gateway (`settings.gateway.platforms.telegram.enabled = true`) with secret environment loading.
  - Python runtime environment **MUST** include `messaging` and `web` dependency groups.

### 2. Image Generation Pipeline (`comfyui.nix`)
- **Capability**: Runs model inference for image generation pipelines.
- **Contract**:
  - **MUST** expose standard options (`my.comfyui.enable`, `cpuOnly`, `sharedModels`, `expose`).
  - Models **MUST** be stored on the shared AI dataset (`/mnt/ai/comfyui/models`) to prevent duplicate storage bloat.

### 3. Search & Information Ingress (`searxng.nix`)
- **Capability**: Serves privacy-preserving search results.
- **Contract**: **MUST** expose an HTTP API endpoint to allow programmatic search integration for local AI agents.

### 4. Fleet Dashboard (`homepage.nix`)
- **Capability**: Single-pane-of-glass dashboard displaying status and links for all hosted services across the fleet.
- **Contract**: **MUST** dynamically expose active services (ComfyUI, Forgejo, Hermes, Immich, Jellyfin, SearXNG, Vaultwarden, IT-Tools).

### 5. Password Management (`vaultwarden.nix`)
- **Capability**: Bitwarden-compatible password vault server.
- **Contract**: **MUST** store data on encrypted persistent storage with automated backup integration.

### 6. Code Hosting (`forgejo.nix`)
- **Capability**: Self-hosted, lightweight Git server with web UI, pull requests, issue tracking, and repository management.
- **Contract**:
  - **MUST** store state on persistent local storage (`/mnt/local/appdata/forgejo`).
  - **MUST** expose HTTP web UI on port `3000` and SSH daemon on port `2222`.
  - **MUST** be registered on the Fleet Dashboard (`homepage.nix`).

