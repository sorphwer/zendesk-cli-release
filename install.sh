#!/bin/sh
# Zendesk CLI one-line installer
# Usage: curl -fsSL https://raw.githubusercontent.com/sorphwer/zendesk-cli-release/main/install.sh | sh
set -e

REPO="sorphwer/zendesk-cli-release"
INSTALL_DIR="$HOME/.zendesk-cli"

info()  { printf '  \033[1;34m>\033[0m %s\n' "$1"; }
error() { printf '  \033[1;31mError:\033[0m %s\n' "$1" >&2; exit 1; }

# --- Detect OS and architecture ---
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Darwin) PLATFORM="macos" ;;
    Linux)  PLATFORM="linux" ;;
    *)      error "Unsupported OS: $OS" ;;
esac

case "$ARCH" in
    arm64|aarch64) ARCH_TAG="arm64" ;;
    x86_64|amd64)  ARCH_TAG="amd64" ;;
    *)             error "Unsupported architecture: $ARCH" ;;
esac

# macOS builds are arm64 only; Linux builds are amd64 only
if [ "$PLATFORM" = "macos" ] && [ "$ARCH_TAG" = "amd64" ]; then
    info "No native x64 build; using arm64 build via Rosetta 2"
    ARCH_TAG="arm64"
fi
if [ "$PLATFORM" = "linux" ] && [ "$ARCH_TAG" = "arm64" ]; then
    error "Linux arm64 builds are not available yet"
fi

ASSET_PATTERN="zendesk-cli-.*-${PLATFORM}-${ARCH_TAG}"

# --- Find latest release ---
info "Fetching latest release from $REPO ..."

LATEST_URL="https://api.github.com/repos/${REPO}/releases/latest"
RELEASE_JSON="$(curl -fsSL "$LATEST_URL")" || error "Failed to fetch latest release"

TAG="$(printf '%s' "$RELEASE_JSON" | grep '"tag_name"' | head -1 | sed 's/.*: *"\(.*\)".*/\1/')"
[ -n "$TAG" ] || error "Could not determine latest version"

info "Latest version: $TAG"

# Find the matching asset download URL
DOWNLOAD_URL="$(printf '%s' "$RELEASE_JSON" | grep '"browser_download_url"' | grep -E "$ASSET_PATTERN" | head -1 | sed 's/.*: *"\(.*\)".*/\1/')"
[ -n "$DOWNLOAD_URL" ] || error "No asset found matching $ASSET_PATTERN"

FILENAME="$(basename "$DOWNLOAD_URL")"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

info "Downloading $FILENAME ..."
curl -fsSL -o "$TMPDIR/$FILENAME" "$DOWNLOAD_URL" || error "Download failed"

# --- Install ---
mkdir -p "$INSTALL_DIR"

case "$FILENAME" in
    *.dmg)
        # macOS: mount DMG, copy contents, unmount
        MOUNT_POINT="$TMPDIR/dmg-mount"
        mkdir -p "$MOUNT_POINT"
        hdiutil attach "$TMPDIR/$FILENAME" -mountpoint "$MOUNT_POINT" -nobrowse -quiet || error "Failed to mount DMG"

        cp "$MOUNT_POINT/zendesk" "$INSTALL_DIR/zendesk"
        chmod +x "$INSTALL_DIR/zendesk"
        if [ -d "$MOUNT_POINT/skills" ]; then
            rm -rf "$INSTALL_DIR/skills"
            cp -r "$MOUNT_POINT/skills" "$INSTALL_DIR/skills"
        fi

        hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true
        ;;
    *.tar.gz)
        # Linux: extract and copy
        EXTRACT_DIR="$TMPDIR/extract"
        mkdir -p "$EXTRACT_DIR"
        tar -xzf "$TMPDIR/$FILENAME" -C "$EXTRACT_DIR"

        cp "$EXTRACT_DIR/zendesk" "$INSTALL_DIR/zendesk"
        chmod +x "$INSTALL_DIR/zendesk"
        if [ -d "$EXTRACT_DIR/skills" ]; then
            rm -rf "$INSTALL_DIR/skills"
            cp -r "$EXTRACT_DIR/skills" "$INSTALL_DIR/skills"
        fi
        ;;
    *)
        error "Unknown file format: $FILENAME"
        ;;
esac

# --- Add to PATH ---
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "$(command -v zsh 2>/dev/null)" ]; then
    RC_FILE="$HOME/.zshrc"
else
    RC_FILE="$HOME/.bashrc"
fi

PATH_LINE='export PATH="$HOME/.zendesk-cli:$PATH"'

if [ -f "$RC_FILE" ] && grep -qF '.zendesk-cli' "$RC_FILE"; then
    : # already configured
else
    printf '\n# Zendesk CLI\n%s\n' "$PATH_LINE" >> "$RC_FILE"
    info "Added ~/.zendesk-cli to PATH in $RC_FILE"
fi

export PATH="$INSTALL_DIR:$PATH"

# --- Verify ---
INSTALLED_VER="$("$INSTALL_DIR/zendesk" --version 2>/dev/null || echo "unknown")"

echo ""
echo "==================================="
echo "  Zendesk CLI $INSTALLED_VER installed!"
echo "==================================="
echo ""
echo "Next steps:"
echo ""
echo "  1. Open a NEW terminal (or run: source $RC_FILE)"
echo "  2. Run:  zendesk init"
echo "  3. Try:  zendesk tickets -n 5"
echo ""
