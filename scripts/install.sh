#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-latest}"
INSTALL_DIR="${HOME}/.local/bin"
REPO="holy-tiger/qqbot-go"

# Resolve version
if [ "$VERSION" = "latest" ]; then
  VERSION=$(curl -sfL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
  if [ -z "$VERSION" ]; then
    echo "Error: failed to resolve latest version" >&2
    exit 1
  fi
fi

echo "Installing qqbot ${VERSION}..."

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
WINDOWS_MODE=false

case "$OS" in
  linux)            ;;
  darwin)           ;;
  mingw*|msys*|cygwin*)
    OS="windows"
    WINDOWS_MODE=true
    ;;
  *)      echo "Unsupported OS: ${OS}" >&2; exit 1 ;;
esac
case "$ARCH" in
  x86_64|amd64) ARCH_SUFFIX="x86_64" ;;
  aarch64|arm64) ARCH_SUFFIX="aarch64" ;;
  *)              echo "Unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

ARCHIVE="qqbot_${OS}_${ARCH_SUFFIX}"
TMPDIR=$(mktemp -d)

if [ "$WINDOWS_MODE" = true ]; then
  EXT="zip"
  URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARCHIVE}.zip"
else
  EXT="tar.gz"
  URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARCHIVE}.tar.gz"
fi

echo "Downloading ${URL}..."
curl -fSL -o "${TMPDIR}/${ARCHIVE}.${EXT}" "$URL"

if [ "$WINDOWS_MODE" = true ]; then
  unzip -q "${TMPDIR}/${ARCHIVE}.zip" -d "${TMPDIR}"
else
  tar -xzf "${TMPDIR}/${ARCHIVE}.tar.gz" -C "${TMPDIR}"
fi

# Install binaries
mkdir -p "$INSTALL_DIR"
if [ "$WINDOWS_MODE" = true ]; then
  cp "${TMPDIR}/qqbot.exe" "${INSTALL_DIR}/qqbot.exe"
  cp "${TMPDIR}/qqbot-channel.exe" "${INSTALL_DIR}/qqbot-channel.exe"
else
  cp "${TMPDIR}/qqbot" "${INSTALL_DIR}/qqbot"
  cp "${TMPDIR}/qqbot-channel" "${INSTALL_DIR}/qqbot-channel"
  chmod +x "${INSTALL_DIR}/qqbot" "${INSTALL_DIR}/qqbot-channel"
fi

# Ensure INSTALL_DIR is in PATH
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
  SHELL_RC="${HOME}/.bashrc"
  if [ -f "${HOME}/.zshrc" ]; then
    SHELL_RC="${HOME}/.zshrc"
  fi
  echo "" >> "$SHELL_RC"
  echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "$SHELL_RC"
  echo "Added ${INSTALL_DIR} to PATH in ${SHELL_RC}"
  echo "Run 'source ${SHELL_RC}' or start a new shell to apply."
fi

rm -rf "$TMPDIR"
echo ""
echo "Installed:"
if [ "$WINDOWS_MODE" = true ]; then
  echo "  qqbot         -> ${INSTALL_DIR}/qqbot.exe"
  echo "  qqbot-channel -> ${INSTALL_DIR}/qqbot-channel.exe"
else
  echo "  qqbot         -> ${INSTALL_DIR}/qqbot"
  echo "  qqbot-channel -> ${INSTALL_DIR}/qqbot-channel"
fi
