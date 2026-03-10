#!/bin/bash
# Fix: removes invalid tools key from agents.defaults, adds tools at root level
python3 << 'PYEOF'
import json
p = "/Users/razin/.openclaw/openclaw.json"
with open(p) as f:
    d = json.load(f)

# Remove the invalid key that broke things
if "agents" in d and "defaults" in d["agents"] and "tools" in d["agents"]["defaults"]:
    del d["agents"]["defaults"]["tools"]

# Add tools at ROOT level with full access
d["tools"] = {
    "exec": {
        "security": "allow",
        "host": "gateway"
    },
    "fs": {
        "workspaceOnly": False
    },
    "elevated": {
        "enabled": True
    }
}

with open(p, "w") as f:
    json.dump(d, f, indent=2)
print("Done! Tools fixed and enabled at root level.")
PYEOF
