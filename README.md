# qqbot-channel

CodeBuddy Code plugin for QQ Bot MCP Channel Server.

Bridges QQ messaging (C2C private chat, group chat, guild channel, guild DM) to CodeBuddy Code via the MCP protocol.

## Features

- **Message forwarding** - Receive QQ messages as MCP notifications in CodeBuddy Code
- **Reply** - Send text, images, voice, video, and file messages back to QQ
- **Scheduled reminders** - Set and cancel cron-based reminders via MCP tools
- **Permission relay** - Forward tool call approval requests to QQ users for remote review
- **Rich media** - Full support for images, voice (Edge TTS + SILK encoding), video, and file attachments
- **Multi-chat** - Supports C2C, group, guild channel, and guild DM conversations

## Prerequisites

- CodeBuddy Code with plugin support
- A QQ Bot application (App ID + App Secret) from [QQ Open Platform](https://q.qq.com)
- **ffmpeg/ffprobe** - Required for audio processing (voice message encoding/format conversion). TTS is built-in (Edge TTS), no separate TTS installation needed.

### Install ffmpeg

```bash
# Debian/Ubuntu
sudo apt install ffmpeg

# macOS
brew install ffmpeg

# Windows (via Chocolatey)
choco install ffmpeg
```

## Supported Platforms

| OS | Architecture | Environment |
|----|--------------|-------------|
| Linux | x86_64, aarch64 | Native |
| macOS | x86_64, aarch64 | Native |
| Windows | x86_64, aarch64 | Git Bash / MSYS2 / Cygwin |

## Installation

### 1. Add marketplace

```bash
codebuddy plugin marketplace add https://github.com/holy-tiger/qqbot-channel-codebuddy
```

### 2. Install plugin

```bash
codebuddy plugin install qqbot-channel@qqbot-channel-codebuddy
```

### 3. Enable plugin

```bash
codebuddy plugin enable qqbot-channel
```

### 4. Run setup

手动运行安装脚本，按提示完成配置：

```bash
# 交互式安装（推荐）
bash ~/.codebuddy/plugins/cache/qqbot-channel-qqbot-channel-codebuddy/scripts/setup.sh

# 或直接传入凭证
bash ~/.codebuddy/plugins/cache/qqbot-channel-qqbot-channel-codebuddy/scripts/setup.sh YOUR_APP_ID YOUR_APP_SECRET
```

安装向导会依次提示输入：

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| appId | QQ Bot 应用 ID（https://q.qq.com 获取） | 无，必填 |
| clientSecret | QQ Bot 客户端密钥 | 无，必填 |
| Bot 名称 | 机器人显示名称 | My QQ Bot |
| System Prompt | 系统提示词 | You are a helpful assistant. |
| 私聊策略 | open / whitelist / close | open |

如需修改配置，重新运行 `setup.sh` 即可（会提示是否覆盖现有配置）。

### 文件位置

| 文件 | 路径 |
|------|------|
| qqbot 二进制 | `~/.local/bin/qqbot` |
| 配置文件 | `~/.local/bin/qqbot-config.yaml` |

## Configuration

### MCP Tools

#### `reply` - 回复 QQ 消息

发送文本或富媒体消息到指定的会话。不设置 `media_type` 则发送纯文本。

| Parameter | Required | Description |
|-----------|----------|-------------|
| `chat_id` | Yes | 会话 ID，格式见下方 chat_id Format |
| `text` | Yes | 要发送的文本内容。纯文本消息时为消息正文；媒体消息时为图片说明/文件描述等 |
| `media_type` | No | 媒体类型，可选: `image` (图片), `file` (文件), `voice` (语音), `video` (视频)。不设置则发送纯文本 |
| `media_url` | No | 媒体文件的 URL。`media_type` 为 `image`/`file`/`video` 时必填 |

**语音消息说明**: `media_type` 设为 `voice` 时，插件内部使用 Edge TTS 自动将 `text` 转为语音发送。**不要自行安装 edge-tts 或任何 TTS 工具**，直接调用 `reply` 工具并设置 `media_type="voice"` 即可，无需提供 `media_url`。

**使用示例**:

```
# 发送纯文本
reply(chat_id="c2c:o_abc123", text="你好！")

# 发送语音（text 内容会被 Edge TTS 转为语音）
reply(chat_id="group:grp_abc123", text="这是一条语音消息", media_type="voice")

# 发送图片
reply(chat_id="c2c:o_abc123", text="看这张图", media_type="image", media_url="https://example.com/photo.jpg")
```

#### `remind` - 设置定时提醒

到时间后通过 qqbot 向指定会话发送文本消息。不设置 `schedule` 则立即发送一次。仅支持 c2c 和 group 类型会话。

| Parameter | Required | Description |
|-----------|----------|-------------|
| `chat_id` | Yes | 会话 ID，格式: `c2c:user_openid` (私聊) 或 `group:group_openid` (群聊) |
| `text` | Yes | 提醒内容文本 |
| `schedule` | No | 定时规则。支持 `@every 30m` (间隔) 或 5 字段 cron 表达式。不设置则立即发送一次 |

**使用示例**:

```
# 立即发送一次
remind(chat_id="c2c:o_abc123", text="该喝水了！")

# 每 30 分钟提醒一次
remind(chat_id="c2c:o_abc123", text="该喝水了！", schedule="@every 30m")

# 使用 cron 表达式（每天 9:00）
remind(chat_id="group:grp_abc123", text="早上好！", schedule="0 9 * * *")
```

#### `cancel_reminder` - 取消定时提醒

取消一个已设置的定时提醒。

| Parameter | Required | Description |
|-----------|----------|-------------|
| `job_id` | Yes | 提醒任务 ID（由 `remind` 工具返回） |

**使用示例**:

```
cancel_reminder(job_id="abc123")
```

### chat_id Format

| Type | Format | Example |
|------|--------|---------|
| C2C (private) | `c2c:{user_openid}` | `c2c:o_abc123` |
| Group | `group:{group_openid}` | `group:grp_abc123` |
| Guild channel | `channel:{channel_id}` | `channel:12345` |
| Guild DM | `dm:{channel_id}` | `dm:54321` |

### Permission Relay

When enabled, tool call approval requests from CodeBuddy Code are forwarded to the QQ user. Users reply with `yes <id>` or `no <id>` to approve or deny.

## Troubleshooting

### Binary download fails

The install script downloads from GitHub Releases. If this fails:

1. Manually download from [qqbot-go releases](https://github.com/holy-tiger/qqbot-go/releases)
2. Extract `qqbot` and `qqbot-channel` to `~/.local/bin/`
3. Make executable: `chmod +x ~/.local/bin/qqbot ~/.local/bin/qqbot-channel`

### Manually create config

If you can't run `setup.sh`, create the config file manually:

```bash
cat > ~/.local/bin/qqbot-config.yaml <<'YAML'
qqbot:
  appId: "YOUR_APP_ID"
  clientSecret: "YOUR_APP_SECRET"
  enabled: true
  name: "My QQ Bot"
  systemPrompt: "You are a helpful assistant."
  dmPolicy: "open"
YAML
```

### Marketplace update fails (git pull error 128)

Network connectivity issue — the plugin marketplace fetches updates from GitHub. If your network blocks GitHub access:

1. Set a proxy: `export https_proxy=http://your-proxy:port`
2. Or use a GitHub mirror
3. Then retry: `codebuddy plugin marketplace add https://github.com/holy-tiger/qqbot-channel-codebuddy`

## Related

- [qqbot-go](https://github.com/holy-tiger/qqbot-go) - QQ Bot API service
- [qqbot-channel-codebuddy releases](https://github.com/holy-tiger/qqbot-channel-codebuddy/releases)

## License

MIT
