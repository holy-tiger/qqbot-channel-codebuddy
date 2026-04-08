#!/usr/bin/env bash
set -euo pipefail

# Setup script for qqbot-channel plugin
# Installs the qqbot binary and generates config.yaml interactively.
# Config file is placed alongside the binary at ~/.local/bin/qqbot-config.yaml
#
# Usage:
#   bash scripts/setup.sh              # interactive, prompts for all fields
#   bash scripts/setup.sh <appId> <clientSecret>  # non-interactive

INSTALL_DIR="${HOME}/.local/bin"
CONFIG_FILE="${INSTALL_DIR}/qqbot-config.yaml"

echo "========================================"
echo "  qqbot-channel 插件安装配置"
echo "========================================"
echo ""

# ── Step 1: Check / install dependencies ────────────────────────────
if ! command -v ffmpeg &>/dev/null || ! command -v ffprobe &>/dev/null; then
  echo "⚠️  未检测到 ffmpeg/ffprobe（语音消息编码所需运行时依赖）"

  # Try auto-install
  if command -v apt-get &>/dev/null; then
    INSTALL_CMD="sudo apt-get update && sudo apt-get install -y ffmpeg"
  elif command -v apt &>/dev/null; then
    INSTALL_CMD="sudo apt update && sudo apt install -y ffmpeg"
  elif command -v dnf &>/dev/null; then
    INSTALL_CMD="sudo dnf install -y ffmpeg"
  elif command -v yum &>/dev/null; then
    INSTALL_CMD="sudo yum install -y ffmpeg"
  elif command -v pacman &>/dev/null; then
    INSTALL_CMD="sudo pacman -S --noconfirm ffmpeg"
  elif command -v brew &>/dev/null; then
    INSTALL_CMD="brew install ffmpeg"
  elif command -v choco &>/dev/null; then
    INSTALL_CMD="choco install -y ffmpeg"
  else
    INSTALL_CMD=""
  fi

  if [ -n "$INSTALL_CMD" ]; then
    echo ""
    echo -n "是否自动安装 ffmpeg? (Y/n): "
    read -r AUTO_INSTALL
    if [ "$AUTO_INSTALL" != "n" ] && [ "$AUTO_INSTALL" != "N" ]; then
      echo "正在执行: ${INSTALL_CMD}"
      if eval "$INSTALL_CMD"; then
        echo ""
        echo "[依赖] ffmpeg 安装成功 ✓"
      else
        echo ""
        echo "⚠️  自动安装失败，请手动安装 ffmpeg 后重新运行。"
        exit 1
      fi
    else
      echo ""
      echo "已跳过。语音功能将不可用。"
    fi
  else
    echo ""
    echo "  未识别包管理器，请手动安装 ffmpeg："
    echo "    Debian/Ubuntu:  sudo apt install ffmpeg"
    echo "    macOS:          brew install ffmpeg"
    echo "    Windows:        choco install ffmpeg"
    echo ""
    echo -n "是否继续安装（语音功能将不可用）? (y/N): "
    read -r CONTINUE
    if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
      echo "退出。请先安装 ffmpeg 后重新运行。"
      exit 1
    fi
  fi
  echo ""
else
  echo "[依赖] ffmpeg/ffprobe 已安装 ✓"
  echo ""
fi

# ── Step 2: Install binary ──────────────────────────────────────────
if [ -x "${INSTALL_DIR}/qqbot" ]; then
  echo "[2/3] qqbot 二进制已安装: ${INSTALL_DIR}/qqbot"
else
  echo "[2/3] 正在安装 qqbot 二进制..."
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  bash "${SCRIPT_DIR}/install.sh"
fi
echo ""

# ── Step 3: Collect credentials ─────────────────────────────────────
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

# ── Step 4: Optional settings with defaults ─────────────────────────
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

# ── Step 5: Write config ────────────────────────────────────────────
echo ""
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
echo "  二进制:   ${INSTALL_DIR}/qqbot"
echo "  配置文件: ${CONFIG_FILE}"
echo ""
echo "  下一步:"
echo "    1. 重启 CodeBuddy Code 以加载插件"
echo "    2. 如 MCP 服务器连接失败，检查配置: ${CONFIG_FILE}"
echo "    3. 如需修改配置，重新运行此脚本即可"
echo ""
