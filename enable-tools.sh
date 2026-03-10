#!/bin/bash
# Enables full autonomous tools (filesystem + exec) for the OpenClaw agent
python3 << 'PYEOF'
import json
p = "/Users/razin/.openclaw/openclaw.json"
with open(p) as f:
    d = json.load(f)

# Enable coding profile with full tool access
if "agents" not in d:
    d["agents"] = {}
if "defaults" not in d["agents"]:
    d["agents"]["defaults"] = {}
d["agents"]["defaults"]["tools"] = {
    "profile": "coding",
    "deny": []
}

with open(p, "w") as f:
    json.dump(d, f, indent=2)
print("Done! Full tools enabled (filesystem + exec).")
PYEOF

# Also create the identity files the bot needs
cat > /Users/razin/.openclaw/workspace/USER.md << 'EOF'
Name: Razin
Style: Brutal honesty, no fluff
Focus: Business benefit only
EOF

cat > /Users/razin/.openclaw/workspace/SOUL.md << 'EOF'
Name: Jarvis
Role: Execution & research specialist, business manager
Directive: Do whatever it takes to succeed
EOF

echo "USER.md and SOUL.md saved!"
