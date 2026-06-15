# Hatch Releases

Public binary releases for the private `davaico/hatch` source repository.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/davaico/hatch-releases/main/install.sh | sh
```

To install a specific version:

```sh
curl -fsSL https://raw.githubusercontent.com/davaico/hatch-releases/main/install.sh | HATCH_VERSION=v1.2.3 sh
```

To choose an install directory:

```sh
curl -fsSL https://raw.githubusercontent.com/davaico/hatch-releases/main/install.sh | HATCH_INSTALL_DIR="$HOME/bin" sh
```

## Update

```sh
hatch update
```

Each release includes macOS and Linux archives for `amd64` and `arm64`, plus `checksums.txt`.
