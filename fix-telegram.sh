#!/bin/bash
# Switches OpenClaw from iMessage to Telegram
python3 << 'PYEOF'
import json
p = "/Users/razin/.openclaw/openclaw.json"
with open(p) as f:
    d = json.load(f)
d["channels"] = {
    "telegram": {
        "enabled": True,
        "botToken": "8741049195:AAEihFzAf_H47JfovXL-nomZA8px3nwV50I"
    }
}
d["skills"] = {"load": {"extraDirs": ["~/.openclaw/skills"]}}
with open(p, "w") as f:
    json.dump(d, f, indent=2)
print("Done! Telegram channel configured.")
PYEOF
