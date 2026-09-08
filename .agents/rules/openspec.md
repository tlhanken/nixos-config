# OpenSpec Change & Specification Management Rule

All AI agents (Antigravity, Claude, Hermes, etc.) operating in this workspace MUST strictly follow the OpenSpec specification and change management standard:

1. **Mandatory OpenSpec Workflow**:
   - For any multi-step task, architectural enhancement, new service integration, or schema update, you MUST first draft or consult a change proposal under `openspec/changes/`.
   - Never implement ad-hoc modifications without anchoring them to existing specifications or creating a corresponding change proposal.

2. **Domain Specification Integrity (`openspec/specs/`)**:
   - Specifications under `openspec/specs/` are the authoritative ground truth for fleet architecture, contracts, and placement rules.
   - Any completed architectural change or policy update MUST be documented in the relevant domain specification before the task is considered finished.

3. **Validation Standard**:
   - Every proposal or code change MUST be validated using `nix flake check` or `just check` before completion.
