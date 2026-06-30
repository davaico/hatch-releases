# Hatch Releases

This repository hosts the public installer and binary releases for Hatch, the interactive CLI/TUI for managing repository-backed AI coding environments on Ubuntu VMs.

The source code is maintained privately in `davaico/hatch`. Release artifacts are published here for installation and updates.

## Install

Install the latest release:

```sh
curl -fsSL https://github.com/davaico/hatch-releases/releases/latest/download/install.sh | sh
```

Install a specific version:

```sh
curl -fsSL https://github.com/davaico/hatch-releases/releases/latest/download/install.sh | HATCH_VERSION=v1.2.3 sh
```

Choose an install directory:

```sh
curl -fsSL https://github.com/davaico/hatch-releases/releases/latest/download/install.sh | HATCH_INSTALL_DIR="$HOME/bin" sh
```

By default, the installer writes to `/usr/local/bin`. If that directory is not writable, it uses `sudo`.

To explicitly allow a user-local fallback instead:

```sh
curl -fsSL https://github.com/davaico/hatch-releases/releases/latest/download/install.sh | HATCH_ALLOW_USER_INSTALL=1 sh
```

## Update

```sh
hatch update
```

## Usage

Open the interactive project manager:

```sh
hatch
```

Use the command surface for scripts and repeatable workflows:

```sh
hatch project create \
  --name "Demo Project" \
  --repo https://github.com/OWNER/REPO.git \
  --compass-project compass-project-id \
  --yes

hatch project list
hatch agent list --project "Demo Project"
hatch agent connect <agent>
```

Hatch requires a shared Postgres database for the local CLI/TUI project and agent inventory. On first interactive launch, `hatch` prompts for the database URL, verifies the connection and schema, stores the URL in local settings, then opens the normal TUI. For non-interactive setup, install `goose` separately, point Hatch at Postgres, and apply the schema manually:

```sh
export HATCH_DATABASE_URL="postgres://hatch_user:password@db.example.com:5432/hatch?sslmode=require"
hatch settings set database-url "$HATCH_DATABASE_URL"
goose -dir internal/db/migrations postgres "$HATCH_DATABASE_URL" up
hatch db import-local
```

Apply migrations manually with `goose` before using the shared database; the Hatch CLI does not run database migrations. When `database-url` is saved in local Hatch settings, or when `HATCH_DATABASE_URL` / `--database-url` is set, the CLI/TUI use Postgres directly. Without a configured and migrated database, local project/agent commands fail with setup guidance. The database stores inventory, host metadata, setup history, runtime events, and latest orchestrator state; it does not store GitHub tokens, Compass login tokens, Tailscale client secrets, OpenCode passwords, SSH private keys, or generated agent credentials. Hatch treats the database URL as sensitive and masks it in `hatch settings list`.

Run `hatch project --help` and `hatch agent --help` for the full command reference. Create and repair commands accept secret flags such as `--compass-token`, `--github-token`, `--tailscale-client-id`, and `--tailscale-client-secret`; when omitted, Hatch reads the matching environment variables. Hatch-managed Hetzner agents use Tailscale SSH and do not require local SSH key files; ensure the local device is authorized by Tailscale SSH ACLs to connect to `tag:hatch-agent` as the agent SSH user.

## Supported Platforms

Each release includes checksum-verified `tar.gz` archives for:

- macOS `amd64`
- macOS `arm64`
- Linux `amd64`
- Linux `arm64`

The installer downloads the matching archive for the current platform, verifies it against `checksums.txt`, and installs the `hatch` binary into the selected directory.

## Installer Configuration

The installer supports these environment variables:

- `HATCH_VERSION`: install a specific SemVer tag instead of the latest release.
- `HATCH_INSTALL_DIR`: install into a custom directory.
- `HATCH_ALLOW_USER_INSTALL`: set to `1` to fall back to `$HOME/.local/bin` when the default system install directory is not writable and `sudo` should not be used.
- `HATCH_REPOSITORY`: override the GitHub release repository.
- `HATCH_RELEASE_BASE_URL`: override the release asset base URL.
- `HATCH_LATEST_URL`: override the latest-release API URL.

## Release Contents

Published release assets include:

- `hatch_darwin_amd64.tar.gz`
- `hatch_darwin_arm64.tar.gz`
- `hatch_linux_amd64.tar.gz`
- `hatch_linux_arm64.tar.gz`
- `checksums.txt`
- `install.sh`
