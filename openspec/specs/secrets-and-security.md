# OpenSpec Specification: Secrets & Security Policy

## Intent & Objectives
Define encryption standards, key management policies, and access control invariants across the fleet to ensure zero unencrypted secrets in version control and strict non-interactive SSH authentication.

## Encryption & Secrets Invariants

### 1. Agenix Secrets Management
- All sensitive configuration data (tokens, private keys, API credentials) **MUST** be encrypted using `agenix`.
- Encrypted secret files **MUST** be stored in `nix/modules/secrets/secret_files/encrypted/`.
- Public identity keys for all hosts and administrative users **MUST** be declared in `nix/modules/secrets/keys.nix`.
- Secret decryption **MUST** occur dynamically at boot time on target hosts using system identity SSH keys.

### 2. Secrets Operations Contract
- Creating or updating encrypted secrets **MUST** use `just edit-secret <secret_name>`.
- Adding new host or user keys **MUST** be followed by a full rekey (`just rekey-secrets`) to ensure all encrypted secret files grant access to updated key sets.
- AI Agents **MUST NOT** decrypt or edit `.age` secret files directly. AI Agents **MUST** configure `.nix` modules to use `EnvironmentFile` / agenix secret paths, and instruct the user to edit secrets manually via `just edit-secret <name>`.

### 3. Secret File Inventory (Variable Names Only)
| Encrypted File | Managed Environment Variables |
|---|---|
| `ai-api-keys.age` | `OPENROUTER_API_KEY`, `OPENAI_API_KEY`, `WEBUI_SECRET_KEY`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_ALLOWED_USERS` |
| `github-token.age` | `GITHUB_TOKEN` |
| `searxng-secrets.age` | `SEARXNG_SECRET_KEY` |
| `tailscale_key.age` | `TAILSCALE_AUTH_KEY` |

## System Security & Access Control

### 1. SSH Authentication Policy
- **MUST NOT** permit SSH password authentication (`PasswordAuthentication = false`).
- **MUST NOT** permit keyboard-interactive authentication (`KbdInteractiveAuthentication = false`).
- **MUST** restrict SSH access exclusively to authorized ED25519 public keys listed in host configurations.

### 2. User & Sudo Security Policy
- Administrative user `tlhanken` **MUST** be configured with explicit group permissions (`wheel`, `docker`, `networkmanager`).
- User passwords stored in configuration **MUST** be salted SHA-512 hashes (`mkpasswd -m sha-512`).
