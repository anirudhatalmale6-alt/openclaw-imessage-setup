---
metadata:
  openclaw:
    emoji: "📊"
    bins:
      - bash
---

# Bot Status (/status)

## Description

Report the current health and status of the OpenClaw gateway when the user sends `/status`.
Provides a quick dashboard-style summary including uptime, resource usage, and active tasks.

## When to activate

Activate when the user message is `/status` (with or without trailing whitespace).

## Behavior

1. Gather the following system information:
   - **Gateway uptime**: How long the OpenClaw gateway has been running
   - **System uptime**: How long the Mac has been on (`uptime`)
   - **CPU usage**: Current CPU load (`top -l 1 -n 0 | grep "CPU usage"`)
   - **Memory**: Free/used RAM (`vm_stat` or `memory_pressure`)
   - **Disk**: Available disk space (`df -h /`)
   - **Active tasks**: Any currently running agent tasks
   - **Last command**: The most recent /run command executed (from task-runner.log)

2. Format the response as a clean, readable summary:

```
📊 OpenClaw Status Report
━━━━━━━━━━━━━━━━━━━━━━
🟢 Gateway: Running
⏱️ Uptime: 2h 34m
💻 CPU: 12% used
🧠 Memory: 8.2 GB / 16 GB
💾 Disk: 234 GB free
📋 Active tasks: 0
🕐 Last command: echo "Hello" (3 min ago)
```

3. If the gateway is unhealthy or any check fails, include a warning.

## Examples

User: `/status`
→ Reply with the full status report

User: `/status`  (with extra spaces)
→ Same behavior, trim whitespace
