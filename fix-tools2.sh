#!/bin/bash
# Fix tools config - correct security value
python3 << 'PYEOF'
import json
p = "/Users/razin/.openclaw/openclaw.json"
with open(p) as f:
    d = json.load(f)

# Fix the tools section with correct values
d["tools"] = {
    "exec": {
        "security": "full",
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
print("Done! Tools config fixed.")
PYEOF
