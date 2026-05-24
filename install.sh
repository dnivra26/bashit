#!/bin/sh
# bashit installer — downloads the latest release for your platform,
# installs the binary to /usr/local/bin, and the zsh widget to
# /usr/local/share/bashit. Override paths with BASHIT_INSTALL_DIR / BASHIT_SHARE_DIR.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/dnivra26/bashit/main/install.sh | sh

set -eu

REPO="dnivra26/bashit"
INSTALL_DIR="${BASHIT_INSTALL_DIR:-/usr/local/bin}"
SHARE_DIR="${BASHIT_SHARE_DIR:-/usr/local/share/bashit}"

say()  { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "missing required tool: $1"; }
need curl
need tar
need uname

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$OS-$ARCH" in
  darwin-arm64)         TARGET="aarch64-apple-darwin" ;;
  darwin-x86_64)        TARGET="x86_64-apple-darwin" ;;
  linux-x86_64)         TARGET="x86_64-unknown-linux-gnu" ;;
  linux-aarch64|linux-arm64) TARGET="aarch64-unknown-linux-gnu" ;;
  *) die "unsupported platform: $OS-$ARCH" ;;
esac

ASSET="bashit-${TARGET}.tar.gz"
BASE_URL="https://github.com/${REPO}/releases/latest/download"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT INT TERM
cd "$tmpdir"

say "→ downloading $ASSET"
curl -fsSL -o "$ASSET" "${BASE_URL}/${ASSET}" || die "download failed; check that a release exists at github.com/${REPO}/releases"
curl -fsSL -o checksums.txt "${BASE_URL}/checksums.txt" || warn "no checksums.txt in release; skipping verification"

if [ -s checksums.txt ]; then
  if command -v shasum >/dev/null 2>&1; then
    actual=$(shasum -a 256 "$ASSET" | awk '{print $1}')
  elif command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$ASSET" | awk '{print $1}')
  else
    warn "no sha256 tool found; skipping verification"
    actual=""
  fi
  if [ -n "$actual" ]; then
    expected=$(awk -v a="$ASSET" '$2 == a {print $1}' checksums.txt)
    [ -n "$expected" ] || die "checksums.txt does not list $ASSET"
    [ "$expected" = "$actual" ] || die "checksum mismatch for $ASSET"
    say "→ verified sha256"
  fi
fi

tar xzf "$ASSET"
cd "bashit-${TARGET}"

# Decide whether sudo is needed for each destination.
sudo_for() {
  parent=$(dirname "$1")
  if [ -d "$parent" ] && [ -w "$parent" ]; then
    echo ""
  elif [ -d "$1" ] && [ -w "$1" ]; then
    echo ""
  else
    command -v sudo >/dev/null 2>&1 || die "$1 not writable and sudo not available"
    echo "sudo"
  fi
}

say "→ installing binary to $INSTALL_DIR/bashit"
S=$(sudo_for "$INSTALL_DIR")
$S mkdir -p "$INSTALL_DIR"
$S install -m 755 bashit "$INSTALL_DIR/bashit"

say "→ installing widget to $SHARE_DIR/bashit.zsh"
S=$(sudo_for "$SHARE_DIR")
$S mkdir -p "$SHARE_DIR"
$S install -m 644 bashit.zsh "$SHARE_DIR/bashit.zsh"

cat <<EOF

✓ bashit installed.

next steps:
  1. set your API key:
       export OPENAI_API_KEY=sk-...
     (optional: OPENAI_BASE_URL and OPENAI_MODEL — defaults to api.openai.com / gpt-4o-mini)

  2. enable the Ctrl+G widget by adding this to ~/.zshrc:
       source $SHARE_DIR/bashit.zsh

  3. reload your shell (\`source ~/.zshrc\` or open a new terminal),
     type a natural-language prompt, and press Ctrl+G.
EOF
