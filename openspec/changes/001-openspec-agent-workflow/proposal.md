# OpenSpec Change Proposal: 001-openspec-agent-workflow

## Summary
Establish OpenSpec (`@fission-ai/openspec`) as the default change management and specification standard for all AI agents (Antigravity, Hermes, Claude Code) working in this repository.

## Motivation
Standardize architecture contracts, component specifications, and change validation across multiple AI agent tools to prevent regression and preserve system invariants across NixOS hosts and Home Manager profiles.

## User Review Required
> [!IMPORTANT]
> All future multi-step or non-trivial agent tasks will be documented as OpenSpec change proposals under `openspec/changes/` and validated against domain specifications in `openspec/specs/`.

## Proposed Changes
- Create `openspec/config.yaml` specifying default agent directives and path mappings.
- Create domain specifications in `openspec/specs/` covering architecture, hosts, services, home manager profiles, networking, and secrets.
- Update `AGENTS.md` to document OpenSpec as the default workflow requirement for AI coding agents.

## Verification Plan
- Verify all specification files contain intent contracts (RFC 2119 keywords).
- Verify flake evaluation with `just check` (`nix flake check`).
