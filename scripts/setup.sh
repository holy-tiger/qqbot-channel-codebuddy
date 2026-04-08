#!/usr/bin/env bash
set -euo pipefail

# Manual setup script for qqbot-channel plugin
# Use this when the SessionStart hook fails to generate config.yaml
#
# Usage:
#   bash scripts/setup.sh
#   bash scripts/setup.sh <appId> <clientSecret>

PLUGIN_NAME="qqbot-channel"
PLUGIN_DATA="${CODEBUDDY_PLUGIN_DATA:-${HOME}/.codebuddy/plugins/data/qqbot-channel-qqbot-channel-codebuddy}"
CONFIG_FILE="${PLUGIN_DATA}/config.yaml"

echo "=== qqbot-channel plugin setup ==="
echo ""

# Step 1: Install binary
if [ -x "${HOME}/.local/bin/qqbot" ]; then
  echo "[1/3] qqbot binary already installed at ${HOME}/.local/bin/qqbot"
else
  echo "[1/3] Installing qqbot binary..."
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  bash "${SCRIPT_DIR}/install.sh"
fi

# Step 2: Get credentials
if [ -n "${1:-}" ] && [ -n "${2:-}" ]; then
  APP_ID="$1"
  CLIENT_SECRET="$2"
else
  # Try reading from settings.json
  SETTINGS_FILE="${HOME}/.codebuddy/settings.json"
  if [ -f "$SETTINGS_FILE" ]; then
    APP_ID=$(grep -o '"appId"[[:space:]]*:[[:space:]]*"[^"]*"' "$SETTINGS_FILE" | head -1 | sed 's/.*"appId"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/' || true)
    CLIENT_SECRET=$(grep -o '"clientSecret"[[:space:]]*:[[:space:]]*"[^"]*"' "$SETTINGS_FILE" | head -1 | sed 's/.*"clientSecret"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/' || true)
  fi

  if [ -z "${APP_ID:-}" ]; then
    echo -n "Enter your QQ Bot appId: "
    read -r APP_ID
  fi
  if [ -z "${CLIENT_SECRET:-}" ]; then
    echo -n "Enter your QQ Bot clientSecret: "
    read -r CLIENT_SECRET
  fi
fi

if [ -z "$APP_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Error: appId and clientSecret are required." >&2
  echo "Get them from https://q.qq.com" >&2
  exit 1
fi

# Step 3: Create config
echo "[2/3] Creating plugin data directory: ${PLUGIN_DATA}"
mkdir -p "${PLUGIN_DATA}"

echo "[3/3] Writing config to ${CONFIG_FILE}"
cat > "${CONFIG_FILE}" <<YAML
qqbot:
  appId: "${APP_ID}"
  clientSecret: "${CLIENT_SECRET}"
  enabled: true
  name: "My QQ Bot"
  systemPrompt: "You are a helpful assistant."
  dmPolicy: "open"
YAML

echo ""
echo "=== Setup complete ==="
echo "Config: ${CONFIG_FILE}"
echo ""
echo "Next steps:"
echo "  1. Restart CodeBuddy Code to load the plugin"
echo "  2. If MCP server fails to connect, check config at: ${CONFIG_FILE}"
