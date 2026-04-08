# qqbot-channel

CodeBuddy Code plugin for QQ Bot MCP Channel Server.

Bridges QQ messaging (C2C private chat, group chat, guild channel, guild DM) to CodeBuddy Code via the MCP protocol.

## Features

- **Message forwarding** - Receive QQ messages as MCP notifications in CodeBuddy Code
- **Reply** - Send text, images, voice, video, and file messages back to QQ
- **Scheduled reminders** - Set and cancel cron-based reminders via MCP tools
- **Permission relay** - Forward tool call approval requests to QQ users for remote review
- **Rich media** - Full support for images, voice (SILK/ASR), video, and file attachments
- **Multi-chat** - Supports C2C, group, guild channel, and guild DM conversations

## Prerequisites

- CodeBuddy Code with plugin support
- A QQ Bot application (App ID + App Secret) from [QQ Open Platform](https://q.qq.com)

## Supported Platforms

| OS | Architecture | Environment |
|----|--------------|-------------|
| Linux | x86_64, aarch64 | Native |
| macOS | x86_64, aarch64 | Native |
| Windows | x86_64, aarch64 | Git Bash / MSYS2 / Cygwin |

## Installation

### 1. Add marketplace

```
codebuddy plugin marketplace add https://github.com/holy-tiger/qqbot-channel-codebuddy
```

### 2. Install plugin

```
codebuddy plugin install qqbot-channel@qqbot-channel-codebuddy
```

### 3. Configure credentials

**In CodeBuddy Code interactive mode** (recommended):

When enabling the plugin, CodeBuddy Code will prompt you to enter:

- **appId** - QQ Bot 应用 ID（可在 https://q.qq.com 获取）
- **clientSecret** - QQ Bot 客户端密钥（敏感信息，存储在系统钥匙串中）

**In CLI mode** (if the prompt does not appear):

Manually add credentials to `~/.codebuddy/settings.json`:

```json
{
  "pluginConfigs": {
    "qqbot-channel@qqbot-channel-codebuddy": {
      "options": {
        "appId": "YOUR_APP_ID",
        "clientSecret": "YOUR_APP_SECRET"
      }
    }
  }
}
```

### 4. Enable plugin

```
codebuddy plugin enable qqbot-channel
```

The `SessionStart` hook will automatically:

1. Download and install the `qqbot` binary (if not already installed)
2. Generate `config.yaml` using your credentials into the plugin data directory

## Configuration

### MCP Tools

| Tool | Description |
|------|-------------|
| `reply` | Send a message to a QQ chat |
| `remind` | Set a scheduled reminder (C2C/group) |
| `cancel_reminder` | Cancel a scheduled reminder |

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

### Config file not generated

If the bot doesn't connect after installation, the `config.yaml` may not have been created. This happens when `CODEBUDDY_PLUGIN_DATA` is unavailable or credentials weren't passed to the hook.

Run the manual setup script:

```bash
# Interactive (will prompt for credentials)
bash ~/.codebuddy/plugins/cache/qqbot-channel-qqbot-channel-codebuddy/scripts/setup.sh

# Or pass credentials directly
bash ~/.codebuddy/plugins/cache/qqbot-channel-qqbot-channel-codebuddy/scripts/setup.sh YOUR_APP_ID YOUR_APP_SECRET
```

Or create the config manually:

```bash
mkdir -p ~/.codebuddy/plugins/data/qqbot-channel-qqbot-channel-codebuddy

cat > ~/.codebuddy/plugins/data/qqbot-channel-qqbot-channel-codebuddy/config.yaml <<'YAML'
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

This is a network connectivity issue — the plugin marketplace fetches updates from GitHub. If your network blocks GitHub access:

1. Set a proxy: `export https_proxy=http://your-proxy:port`
2. Or use a GitHub mirror
3. Then retry: `codebuddy plugin marketplace add https://github.com/holy-tiger/qqbot-channel-codebuddy`

### Binary download fails

The install script downloads from GitHub Releases. If this fails:

1. Manually download from [qqbot-go releases](https://github.com/holy-tiger/qqbot-go/releases)
2. Extract `qqbot` and `qqbot-channel` to `~/.local/bin/`
3. Make executable: `chmod +x ~/.local/bin/qqbot ~/.local/bin/qqbot-channel`

## Related

- [qqbot-go](https://github.com/holy-tiger/qqbot-go) - QQ Bot API service
- [qqbot-channel-codebuddy releases](https://github.com/holy-tiger/qqbot-channel-codebuddy/releases)

## License

MIT
