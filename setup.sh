#!/bin/bash
#
# OpenClaw + iMessage Quick Setup Script
# Run this on your Mac: bash setup.sh
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo "=========================================="
echo "  OpenClaw + iMessage Setup"
echo "=========================================="
echo ""

# --- Check prerequisites ---
echo -e "${YELLOW}[1/7] Checking prerequisites...${NC}"

# Check macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}Error: This script is for macOS only.${NC}"
    exit 1
fi
echo "  ✅ macOS detected"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed.${NC}"
    echo "  Install it from https://nodejs.org (version 22+)"
    exit 1
fi

NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
    echo -e "${RED}Error: Node.js 22+ required. You have v${NODE_VERSION}.${NC}"
    echo "  Update from https://nodejs.org"
    exit 1
fi
echo "  ✅ Node.js v$(node --version)"

# Check Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}  Homebrew not found. Installing...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
echo "  ✅ Homebrew installed"

# --- Install OpenClaw ---
echo ""
echo -e "${YELLOW}[2/7] Installing OpenClaw...${NC}"

if command -v openclaw &> /dev/null; then
    echo "  ✅ OpenClaw already installed ($(openclaw --version))"
else
    curl -fsSL https://openclaw.ai/install.sh | bash
    echo "  ✅ OpenClaw installed"
fi

# --- Install imsg CLI ---
echo ""
echo -e "${YELLOW}[3/7] Installing iMessage CLI (imsg)...${NC}"

if command -v imsg &> /dev/null; then
    echo "  ✅ imsg already installed"
else
    brew install steipete/tap/imsg
    echo "  ✅ imsg installed"
fi

IMSG_PATH=$(which imsg)
echo "  Path: ${IMSG_PATH}"

# --- Configure iMessage channel ---
echo ""
echo -e "${YELLOW}[4/7] Configuring iMessage channel...${NC}"

MAC_USER=$(whoami)
CONFIG_FILE="$HOME/.openclaw/openclaw.json"
DB_PATH="/Users/${MAC_USER}/Library/Messages/chat.db"

# Check if Messages DB exists
if [ ! -f "$DB_PATH" ]; then
    echo -e "${RED}  Warning: Messages database not found at ${DB_PATH}${NC}"
    echo "  Make sure iMessage is signed in: System Settings → Messages"
fi

# Create config directory if needed
mkdir -p "$HOME/.openclaw"

# Check if config exists
if [ -f "$CONFIG_FILE" ]; then
    echo "  Config file exists. Please manually add the iMessage channel config."
    echo "  See README.md for the JSON snippet to add."
else
    cat > "$CONFIG_FILE" << HEREDOC
{
  "channels": {
    "imessage": {
      "enabled": true,
      "cliPath": "${IMSG_PATH}",
      "dbPath": "${DB_PATH}"
    }
  },
  "skills": {
    "load": {
      "extraDirs": ["~/.openclaw/skills"]
    }
  }
}
HEREDOC
    echo "  ✅ Config created at ${CONFIG_FILE}"
fi

# --- Install custom skills ---
echo ""
echo -e "${YELLOW}[5/7] Installing custom skills (/run, /status, /stop)...${NC}"

SKILLS_DIR="$HOME/.openclaw/skills"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$SKILLS_DIR"

# Copy skills from repo
if [ -d "$SCRIPT_DIR/skills/task-runner" ]; then
    cp -r "$SCRIPT_DIR/skills/task-runner" "$SKILLS_DIR/"
    cp -r "$SCRIPT_DIR/skills/bot-status" "$SKILLS_DIR/"
    cp -r "$SCRIPT_DIR/skills/graceful-stop" "$SKILLS_DIR/"
    echo "  ✅ Skills installed to ${SKILLS_DIR}"
else
    echo -e "${RED}  Skills folder not found. Copy them manually from the repo.${NC}"
fi

# Create log directory for task-runner
mkdir -p "$HOME/.openclaw/logs"

# --- Trigger permissions ---
echo ""
echo -e "${YELLOW}[6/7] Triggering macOS permissions...${NC}"
echo ""
echo -e "${YELLOW}  ⚠️  macOS will show permission dialogs.${NC}"
echo -e "${YELLOW}  ⚠️  Click ALLOW on each one!${NC}"
echo ""
read -p "  Press Enter to trigger permission prompts..."

imsg chats --limit 1 2>/dev/null || true
echo "  ✅ Permissions triggered (check System Settings if you missed a prompt)"

# --- Run onboarding ---
echo ""
echo -e "${YELLOW}[7/7] Starting OpenClaw onboarding...${NC}"
echo ""
echo "  The onboarding wizard will now start."
echo "  You'll need your AI provider API key ready."
echo ""
read -p "  Press Enter to start onboarding..."

if openclaw gateway status 2>/dev/null | grep -q "running"; then
    echo "  ✅ Gateway is already running!"
else
    echo ""
    echo "  Running: openclaw onboard --install-daemon"
    echo ""
    openclaw onboard --install-daemon
fi

# --- Done ---
echo ""
echo "=========================================="
echo -e "${GREEN}  ✅ Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "  Next steps:"
echo "  1. Send an iMessage from your iPhone to this Mac"
echo "  2. Run: openclaw pairing list imessage"
echo "  3. Run: openclaw pairing approve imessage <CODE>"
echo "  4. Try sending: /status"
echo ""
echo "  Control UI: http://127.0.0.1:18789"
echo "  Logs: openclaw gateway --foreground"
echo ""
echo "  Enjoy your AI agent! 🦞"
echo ""
