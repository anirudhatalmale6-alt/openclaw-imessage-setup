# OpenClaw + iMessage Setup Guide for macOS

> Type a command from your iPhone → watch it execute on your Mac. Zero manual intervention.

---

## Prerequisites

| Requirement | How to check |
|-------------|-------------|
| macOS 14+ (Sonoma or Sequoia) | Apple menu → About This Mac |
| Node.js 22+ | `node --version` (install from https://nodejs.org) |
| Homebrew | `brew --version` (install from https://brew.sh) |
| iMessage signed in on Mac | System Settings → Messages → signed in with Apple ID |
| Same Apple ID on iPhone & Mac | Required for iMessage bridging |

---

## Part 1 — Install OpenClaw

Open **Terminal.app** and run each command one at a time:

```bash
# 1. Install OpenClaw
curl -fsSL https://openclaw.ai/install.sh | bash

# 2. Verify installation
openclaw --version

# 3. Run the onboarding wizard (installs as background daemon)
openclaw onboard --install-daemon
```

During the wizard you'll be asked for:
- **AI provider**: Choose **Anthropic** (recommended) or OpenAI
- **API key**: Paste your key from https://console.anthropic.com/settings/keys
- **Gateway bind**: Choose **Loopback** (safest for single-machine use)

> **Important:** Do NOT use `sudo`. Run everything as your normal user.

### Verify gateway is running

```bash
openclaw gateway status
```

You should see `Gateway: running` and a URL like `http://127.0.0.1:18789`.

Open that URL in your browser — you'll see the OpenClaw Control UI.

---

## Part 2 — Set Up iMessage Channel

### Step 2a — Install the iMessage CLI tool

```bash
brew install steipete/tap/imsg
```

### Step 2b — Trigger macOS permission prompts

Run this in a **GUI terminal** (not SSH):

```bash
imsg chats --limit 1
```

macOS will prompt for:
1. **Full Disk Access** — click Allow
2. **Automation** (Messages.app) — click Allow

If you missed a prompt, go to **System Settings → Privacy & Security → Full Disk Access** and add the `imsg` binary manually.

### Step 2c — Test sending a message

```bash
imsg send "+1YOURNUMBER" "Hello from OpenClaw setup test!"
```

You should receive the message on your iPhone.

### Step 2d — Configure OpenClaw for iMessage

Edit your OpenClaw config:

```bash
nano ~/.openclaw/openclaw.json
```

Find the `channels` section (or add it) and set:

```json
{
  "channels": {
    "imessage": {
      "enabled": true,
      "cliPath": "/usr/local/bin/imsg",
      "dbPath": "/Users/YOUR_USERNAME/Library/Messages/chat.db"
    }
  }
}
```

**Replace `YOUR_USERNAME`** with your actual macOS username (run `whoami` to check).

> If you installed via Homebrew on Apple Silicon, the path might be `/opt/homebrew/bin/imsg` instead. Check with `which imsg`.

### Step 2e — Restart gateway and approve pairing

```bash
# Restart the gateway to pick up config changes
openclaw gateway restart

# List pending pairings
openclaw pairing list imessage
```

Now **send any message from your iPhone to your Mac's iMessage**. A pairing code will appear. Approve it:

```bash
openclaw pairing approve imessage <PAIRING_CODE>
```

After approval, your iPhone iMessage is wired to OpenClaw.

---

## Part 3 — Install Custom Skills (/run, /status, /stop)

Copy the three skill folders from this repo into your OpenClaw skills directory:

```bash
# Create the custom skills directory
mkdir -p ~/.openclaw/skills

# Copy the skills (run this from the repo root)
cp -r skills/task-runner ~/.openclaw/skills/
cp -r skills/bot-status ~/.openclaw/skills/
cp -r skills/graceful-stop ~/.openclaw/skills/
```

Then tell OpenClaw to scan this directory. Edit `~/.openclaw/openclaw.json`:

```json
{
  "skills": {
    "load": {
      "extraDirs": ["~/.openclaw/skills"]
    }
  }
}
```

Restart the gateway one more time:

```bash
openclaw gateway restart
```

---

## Part 4 — Test It!

From your iPhone, open iMessage and send these commands to your Mac:

| Command | What it does |
|---------|-------------|
| `/run open -a Safari` | Opens Safari on your Mac |
| `/run echo "Hello World" > ~/Desktop/test.txt` | Creates a file on your Desktop |
| `/status` | Shows gateway health, uptime, active tasks |
| `/stop` | Gracefully shuts down the gateway |

### Full test sequence:

1. **Send from iPhone:** `/status`
   - Expected: You get back gateway status (uptime, memory, active tasks)

2. **Send from iPhone:** `/run echo "OpenClaw works!" > ~/Desktop/openclaw-test.txt`
   - Expected: File appears on your Desktop, confirmation reply in iMessage

3. **Send from iPhone:** `/run open https://github.com`
   - Expected: GitHub opens in your default browser

4. **Send from iPhone:** `What's the weather today?`
   - Expected: OpenClaw responds conversationally (it's a full AI agent!)

5. **Send from iPhone:** `/stop`
   - Expected: Gateway shuts down gracefully, confirmation message sent

To restart after `/stop`:
```bash
openclaw gateway
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `imsg: command not found` | Run `brew install steipete/tap/imsg` |
| No permission prompts | System Settings → Privacy & Security → Full Disk Access → add `imsg` |
| Messages not arriving | Check `openclaw pairing list imessage` — approve any pending codes |
| Gateway won't start | Check logs: `openclaw gateway --foreground` to see errors |
| API key error | Re-run `openclaw onboard` to update your API key |
| "dbPath not found" | Verify path: `ls ~/Library/Messages/chat.db` |
| Apple Silicon path | Use `/opt/homebrew/bin/imsg` instead of `/usr/local/bin/imsg` |

---

## Architecture Overview

```
iPhone (iMessage)
     │
     ▼
macOS Messages.app
     │
     ▼
imsg CLI (reads Messages DB)
     │
     ▼
OpenClaw Gateway (localhost:18789)
     │
     ├── /run   → task-runner skill → executes shell commands
     ├── /status → bot-status skill → reports system health
     └── /stop  → graceful-stop skill → shuts down gateway
```

---

## Telegram Alternative (Backup)

If iMessage gives you trouble, Telegram is the fastest fallback:

1. Message [@BotFather](https://t.me/BotFather) on Telegram → `/newbot` → get your bot token
2. Edit `~/.openclaw/openclaw.json`:

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "YOUR_BOT_TOKEN_HERE"
    }
  }
}
```

3. Restart gateway: `openclaw gateway restart`
4. Message your bot on Telegram — approve pairing the same way

---

## Quick Reference Card

```
/run <command>     Execute any shell command on your Mac
/status            Check gateway health and active tasks
/stop              Gracefully shut down the agent

openclaw gateway status     Check if gateway is running
openclaw gateway restart    Restart the gateway
openclaw gateway            Start gateway in foreground
openclaw dashboard          Open the web control UI
```

---

*Setup guide prepared by Anirudha Talmale*
