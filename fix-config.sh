#!/bin/bash
# Quick config fix - adds iMessage channel to OpenClaw
python3 << 'PYEOF'
import json
p = "/Users/razin/.openclaw/openclaw.json"
with open(p) as f:
    d = json.load(f)
d["channels"] = {
    "imessage": {
        "enabled": True,
        "cliPath": "/opt/homebrew/bin/imsg",
        "dbPath": "/Users/razin/Library/Messages/chat.db"
    }
}
d["skills"] = {"load": {"extraDirs": ["~/.openclaw/skills"]}}
with open(p, "w") as f:
    json.dump(d, f, indent=2)
print("Config updated! iMessage channel added.")
PYEOF
