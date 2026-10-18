# Package Ledger: Out-of-Flake & Fixed-Output Packages

This document serves as the canonical inventory of all packages and applications in this repository that cannot be tracked purely via flake inputs and require fixed-output hashes (`buildNpmPackage`, `fetchurl`, vendored lockfiles, etc.).

---

## Invariant & Policy

1. **Flake-First Rule**: Any dependency with a Git repository or Nix Flake interface **MUST** be declared as a flake input under `flake.nix` with appropriate `inputs.<dep>.follows`.
2. **Zero Silent Pins**: No ad-hoc, untracked `rev`, `hash`, or `npmDepsHash` values may exist in the codebase without being registered in this ledger.
3. **Mandatory Automated Updaters**: Every package registered in this ledger **MUST** have an automated update script under `scripts/update-<package>.sh` and an associated recipe in the `justfile`.
4. **Unified Updates**: Running `just update` updates both the Flake inputs (`nix flake update`) and all ledger packages. Running `just update-apps` (alias: `just ua`) updates all ledger packages.

---

## Package Inventory

| Package | Source File | Upstream | Pin Type | Tracking Target | Hash Dependencies | Update Recipe |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`gods-eye-view`** | [`nix/modules/apps/gods-eye-view.nix`](../nix/modules/apps/gods-eye-view.nix) | GitHub ([`bilawalsidhu/gods-eye-view`](https://github.com/bilawalsidhu/gods-eye-view)) | Git commit | Upstream `main` branch | `hash` (SRI), `npmDepsHash` | `just update-gods-eye-view` (`just ugev`) |
| **`hermes-mod`** | [`nix/packages/hermes-mod.nix`](../nix/packages/hermes-mod.nix) | npm registry ([`hermes-mod`](https://www.npmjs.com/package/hermes-mod)) | npm release tarball | Latest npm release | tarball `hash` (sha256), `npmDepsHash`, `hermes-mod-package-lock.json` | `just update-hermes-mod` |

> **Note on Graduated Packages**:
> - **`openspec`** and **`qmd`** have been moved to native Flake inputs (`inputs.openspec` and `inputs.qmd` in `flake.nix`). They are now tracked automatically in `flake.lock` via `just update` (`nix flake update`) and no longer require out-of-flake ledger maintenance.

---

## Update Workflows

### 1. Update Everything
```bash
just update     # Updates all flake inputs (flake.lock) AND all ledger packages
```

### 2. Update Only Ledger Applications
```bash
just update-apps  # alias: just ua
```

### 3. Update an Individual Application
```bash
just update-gods-eye-view  # alias: just ugev
just update-hermes-mod
```

---

## Adding a New Out-of-Flake Package

When introducing a new package that cannot be purely consumed via a Nix Flake:
1. Define the derivation using standard Nix idioms (`buildNpmPackage`, `fetchurl`, etc.).
2. Write an update script under `scripts/update-<name>.sh` following the existing scripts (fetching upstream releases, generating/verifying lockfiles, prefetching hashes, and applying substitutions).
3. Add the target to `justfile` and chain it into `scripts/update-apps.sh`.
4. Register the package and its hash dependencies in this ledger.
