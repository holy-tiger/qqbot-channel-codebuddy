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

### 3. Install binary

**Linux / macOS:**

```bash
bash scripts/install.sh
```

**Windows (Git Bash):**

```bash
bash scripts/install.sh
```

This downloads the `qqbot` and `qqbot-channel` binaries from [GitHub Releases](https://github.com/holy-tiger/qqbot-go/releases) to `~/.local/bin/`.

On Windows, the binaries will be named `qqbot.exe` and `qqbot-channel.exe`.

### 4. Configure

Edit `~/.qqbot/config.yaml` with your QQ Bot credentials:

```yaml
app_id: "YOUR_APP_ID"
app_secret: "YOUR_APP_SECRET"
webhook_port: 8788
```

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

## Related

- [qqbot-go](https://github.com/holy-tiger/qqbot-go) - QQ Bot API service
- [qqbot-channel-codebuddy releases](https://github.com/holy-tiger/qqbot-channel-codebuddy/releases)

## License

MIT
