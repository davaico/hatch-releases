# Hatch Releases

This repository hosts the public installer and binary releases for Hatch, the interactive CLI/TUI for managing repository-backed AI coding environments on Ubuntu VMs.

The source code is maintained privately in `davaico/hatch`. Release artifacts are published here for installation and updates.

## Install

Install the latest release:

```sh
curl -fsSL https://raw.githubusercontent.com/davaico/hatch-releases/main/install.sh | sh
```

Install a specific version:

```sh
curl -fsSL https://raw.githubusercontent.com/davaico/hatch-releases/main/install.sh | HATCH_VERSION=v1.2.3 sh
```

Choose an install directory:

```sh
curl -fsSL https://raw.githubusercontent.com/davaico/hatch-releases/main/install.sh | HATCH_INSTALL_DIR="$HOME/bin" sh
```

## Update

```sh
hatch update
```

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
