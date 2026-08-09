# Core System Specification: NixOS Fleet Configuration

## Overview & Scope
This repository manages the declarative configuration, system services, user profiles, and storage topology for all home infrastructure devices using NixOS, Home Manager, and the Numtide Blueprint framework.

## Specification Architecture
The system specification is organized into domain-specific contracts under `openspec/specs/`:

- [`core-architecture.md`](file:///home/tlhanken/workspace/nixos-config/openspec/specs/core-architecture.md): Blueprint framework discovery, flake alignment, `justfile` workflow, and `nh` garbage collection standards.
- [`hosts-and-hardware.md`](file:///home/tlhanken/workspace/nixos-config/openspec/specs/hosts-and-hardware.md): Host roles (`sleipnir`, `galar`, `well-of-mimir-2`), hardware passthrough, and provisioning standards.
- [`apps-and-services.md`](file:///home/tlhanken/workspace/nixos-config/openspec/specs/apps-and-services.md): Workload placement rules, AI agent contracts, media servers, and reverse proxy standards.
- [`home-manager-profiles.md`](file:///home/tlhanken/workspace/nixos-config/openspec/specs/home-manager-profiles.md): User environments, developer toolchains, profile composition, and package locking contracts.
- [`networking-and-storage.md`](file:///home/tlhanken/workspace/nixos-config/openspec/specs/networking-and-storage.md): Tailscale IP resolution rules (`lib/network.nix`), `my.mounts` dataset contracts, and NFS access controls.
- [`secrets-and-security.md`](file:///home/tlhanken/workspace/nixos-config/openspec/specs/secrets-and-security.md): Agenix secret encryption, rekeying standards, and non-interactive SSH security policies.

## Agent Directives & OpenSpec Workflow
1. **Default Workflow**: OpenSpec (`@fission-ai/openspec`) is the default specification and change management standard for all AI agents (Antigravity, Hermes, Claude Code).
2. **Intent Over Implementation**: Specifications describe **requirements, capabilities, and non-negotiable contracts**. They MUST NOT contain ephemeral secret hashes, raw scripts, or volatile instance IDs.
3. **Change Proposals**: Non-trivial modifications, new services, or architectural refactors MUST be proposed as change documents under `openspec/changes/`.
4. **Validation Contract**: Every proposed change MUST pass `just check` (`nix flake check`) cleanly before completion.
