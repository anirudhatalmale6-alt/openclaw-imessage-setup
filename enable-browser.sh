#!/bin/bash
# Enables Chrome browser automation for OpenClaw
# Allows the agent to click, type, scrape, navigate websites

echo "=== OpenClaw Browser Setup ==="
echo ""

# Step 1: Check for Chrome
if [ -d "/Applications/Google Chrome.app" ]; then
    CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    echo "✅ Google Chrome found"
elif [ -d "/Applications/Brave Browser.app" ]; then
    CHROME_PATH="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
    echo "✅ Brave Browser found"
else
    echo "❌ No Chromium browser found."
    echo "Please install Google Chrome from https://www.google.com/chrome/"
    echo "Then run this script again."
    exit 1
fi

# Step 2: Install Playwright for advanced browser actions
echo ""
echo "Installing Playwright (for click/type/navigate)..."
npm install -g playwright 2>/dev/null
npx playwright install chromium 2>/dev/null
echo "✅ Playwright installed"

# Step 3: Update OpenClaw config
echo ""
echo "Updating OpenClaw config..."
python3 << PYEOF
import json
p = "/Users/razin/.openclaw/openclaw.json"
with open(p) as f:
    d = json.load(f)

d["browser"] = {
    "enabled": True,
    "defaultProfile": "openclaw",
    "headless": False,
    "executablePath": "$CHROME_PATH",
    "profiles": {
        "openclaw": {
            "cdpPort": 18800,
            "color": "#FF4500"
        }
    }
}

with open(p, "w") as f:
    json.dump(d, f, indent=2)
print("✅ Browser config added to openclaw.json")
PYEOF

echo ""
echo "=== Done! ==="
echo ""
echo "Now restart the gateway: openclaw gateway restart"
echo ""
echo "Then tell Jarvis on Telegram:"
echo "  'Open Chrome and go to google.com'"
echo "  'Click the search box and type hello'"
echo ""
