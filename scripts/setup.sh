#!/usr/bin/env bash
set -euo pipefail

# Setup script for qqbot-channel plugin
# Installs the qqbot binary and generates config.yaml interactively.
#
# Usage:
#   bash scripts/setup.sh              # interactive, prompts for all fields
#   bash scripts/setup.sh <appId> <clientSecret>  # non-interactive

PLUGIN_DATA="${CODEBUDDY_PLUGIN_DATA:-${HOME}/.codebuddy/plugins/data/qqbot-channel-qqbot-channel-codebuddy}"
CONFIG_FILE="${PLUGIN_DATA}/config.yaml"

echo "========================================"
echo "  qqbot-channel 插件安装配置"
echo "========================================"
echo ""

# ── Step 1: Install binary ──────────────────────────────────────────
if [ -x "${HOME}/.local/bin/qqbot" ]; then
  echo "[1/3] qqbot 二进制已安装: ${HOME}/.local/bin/qqbot"
else
  echo "[1/3] 正在安装 qqbot 二进制..."
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  bash "${SCRIPT_DIR}/install.sh"
fi
echo ""

# ── Step 2: Collect credentials ─────────────────────────────────────
# If config already exists, ask whether to overwrite
if [ -f "$CONFIG_FILE" ]; then
  echo "检测到已有配置文件: ${CONFIG_FILE}"
  echo -n "是否覆盖? (y/N): "
  read -r OVERWRITE
  if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
    echo "保留现有配置，退出。"
    exit 0
  fi
  echo ""
fi

# appId
if [ -n "${1:-}" ]; then
  APP_ID="$1"
else
  echo "请输入 QQ Bot 的 appId（可在 https://q.qq.com 获取）"
  echo -n "appId: "
  read -r APP_ID
fi

# clientSecret
if [ -n "${2:-}" ]; then
  CLIENT_SECRET="$2"
else
  echo "请输入 QQ Bot 的 clientSecret"
  echo -n "clientSecret: "
  read -r CLIENT_SECRET
fi

if [ -z "$APP_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "" >&2
  echo "错误: appId 和 clientSecret 不能为空。" >&2
  echo "请在 https://q.qq.com 获取你的机器人凭证。" >&2
  exit 1
fi

# ── Step 3: Optional settings with defaults ─────────────────────────
echo ""
echo "以下为可选配置，直接回车使用默认值："

echo -n "Bot 名称 [My QQ Bot]: "
read -r BOT_NAME
BOT_NAME="${BOT_NAME:-My QQ Bot}"

echo -n "System Prompt [You are a helpful assistant.]: "
read -r SYSTEM_PROMPT
SYSTEM_PROMPT="${SYSTEM_PROMPT:-You are a helpful assistant.}"

echo -n "私聊策略 (open/whitelist/close) [open]: "
read -r DM_POLICY
DM_POLICY="${DM_POLICY:-open}"

case "$DM_POLICY" in
  open|whitelist|close) ;;
  *) DM_POLICY="open" ;;
esac

# ── Step 4: Write config ────────────────────────────────────────────
echo ""
echo "[2/3] 创建数据目录: ${PLUGIN_DATA}"
mkdir -p "${PLUGIN_DATA}"

echo "[3/3] 写入配置文件: ${CONFIG_FILE}"
cat > "${CONFIG_FILE}" <<YAML
qqbot:
  appId: "${APP_ID}"
  clientSecret: "${CLIENT_SECRET}"
  enabled: true
  name: "${BOT_NAME}"
  systemPrompt: "${SYSTEM_PROMPT}"
  dmPolicy: "${DM_POLICY}"
YAML

echo ""
echo "========================================"
echo "  安装配置完成!"
echo "========================================"
echo ""
echo "  配置文件: ${CONFIG_FILE}"
echo ""
echo "  下一步:"
echo "    1. 重启 CodeBuddy Code 以加载插件"
echo "    2. 如 MCP 服务器连接失败，检查配置: ${CONFIG_FILE}"
echo "    3. 如需修改配置，重新运行此脚本即可"
echo ""
