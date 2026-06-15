#!/bin/sh
set -eu

HATCH_REPOSITORY="${HATCH_REPOSITORY:-davaico/hatch-releases}"
HATCH_RELEASE_BASE_URL="${HATCH_RELEASE_BASE_URL:-https://github.com/${HATCH_REPOSITORY}/releases/download}"
HATCH_LATEST_URL="${HATCH_LATEST_URL:-https://api.github.com/repos/${HATCH_REPOSITORY}/releases/latest}"
HATCH_SYSTEM_INSTALL_DIR="${HATCH_SYSTEM_INSTALL_DIR:-/usr/local/bin}"

die() {
	printf 'hatch install: %s\n' "$*" >&2
	exit 1
}

detect_platform() {
	raw_os="${HATCH_TEST_OS:-$(uname -s)}"
	raw_arch="${HATCH_TEST_ARCH:-$(uname -m)}"

	case "$raw_os" in
		Darwin) HATCH_OS="darwin" ;;
		Linux) HATCH_OS="linux" ;;
		*) die "unsupported operating system: $raw_os" ;;
	esac

	case "$raw_arch" in
		x86_64 | amd64) HATCH_ARCH="amd64" ;;
		arm64 | aarch64) HATCH_ARCH="arm64" ;;
		*) die "unsupported architecture: $raw_arch" ;;
	esac

	export HATCH_OS HATCH_ARCH
}

latest_version() {
	if [ "${HATCH_VERSION:-}" ]; then
		printf '%s\n' "$HATCH_VERSION"
		return
	fi

	version="$(curl -fsSL "$HATCH_LATEST_URL" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
	if [ -z "$version" ]; then
		die "could not detect latest release version"
	fi
	printf '%s\n' "$version"
}

sha256_file() {
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum "$1" | awk '{print $1}'
		return
	fi
	if command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$1" | awk '{print $1}'
		return
	fi
	die "sha256sum or shasum is required"
}

verify_checksum() {
	asset="$1"
	archive="$2"
	checksums="$3"

	expected="$(awk -v f="$asset" '$2 == f { print $1; found=1 } END { if (!found) exit 1 }' "$checksums")" || die "checksum for $asset not found"
	actual="$(sha256_file "$archive")"
	if [ "$actual" != "$expected" ]; then
		die "checksum verification failed for $asset"
	fi
}

choose_install_dir() {
	if [ "${HATCH_INSTALL_DIR:-}" ]; then
		printf '%s\n' "$HATCH_INSTALL_DIR"
		return
	fi
	if [ -d "$HATCH_SYSTEM_INSTALL_DIR" ] && [ -w "$HATCH_SYSTEM_INSTALL_DIR" ]; then
		printf '%s\n' "$HATCH_SYSTEM_INSTALL_DIR"
		return
	fi
	printf '%s\n' "$HOME/.local/bin"
}

install_hatch() {
	version="$1"
	asset="$2"
	tmpdir="$3"
	install_dir="$4"
	archive="$tmpdir/$asset"
	checksums="$tmpdir/checksums.txt"
	extract_dir="$tmpdir/extract"

	mkdir -p "$extract_dir" "$install_dir"
	curl -fsSL "$HATCH_RELEASE_BASE_URL/$version/$asset" -o "$archive"
	curl -fsSL "$HATCH_RELEASE_BASE_URL/$version/checksums.txt" -o "$checksums"
	verify_checksum "$asset" "$archive" "$checksums"

	tar -xzf "$archive" -C "$extract_dir"
	binary="$extract_dir/hatch"
	if [ ! -f "$binary" ]; then
		binary="$(find "$extract_dir" -type f -name hatch | head -n 1)"
	fi
	if [ -z "$binary" ] || [ ! -f "$binary" ]; then
		die "hatch binary not found in $asset"
	fi

	target="$install_dir/hatch"
	tmp_target="$install_dir/.hatch.tmp.$$"
	cp "$binary" "$tmp_target"
	chmod 0755 "$tmp_target"
	mv "$tmp_target" "$target"
	printf 'Installed Hatch %s to %s\n' "$version" "$target"
}

main() {
	detect_platform
	version="$(latest_version)"
	asset="hatch_${HATCH_OS}_${HATCH_ARCH}.tar.gz"
	install_dir="$(choose_install_dir)"
	tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/hatch-install.XXXXXX")"
	trap 'rm -rf "$tmpdir"' EXIT INT TERM

	install_hatch "$version" "$asset" "$tmpdir" "$install_dir"
}

if [ "${HATCH_INSTALL_SH_SOURCED:-}" != "1" ]; then
	main "$@"
fi
