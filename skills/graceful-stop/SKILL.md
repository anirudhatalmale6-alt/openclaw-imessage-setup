---
metadata:
  openclaw:
    emoji: "🛑"
    bins:
      - bash
---

# Graceful Stop (/stop)

## Description

Gracefully shut down the OpenClaw gateway when the user sends `/stop`.
Ensures all active tasks complete before shutdown, sends a confirmation message,
and then stops the daemon.

## When to activate

Activate when the user message is `/stop` (with or without trailing whitespace).

## Behavior

1. **Acknowledge immediately**: Reply with "🛑 Shutting down OpenClaw gateway..."
2. **Check for active tasks**: If any tasks are in progress, wait up to 30 seconds for them to finish.
3. **Send final message**: Reply with:
   ```
   🛑 OpenClaw gateway stopped.
   To restart, open Terminal and run:
   openclaw gateway
   ```
4. **Execute shutdown**: Run `openclaw gateway stop` to gracefully stop the daemon.

## Safety rules

- Always send the confirmation message BEFORE stopping (once stopped, you can't send messages)
- If tasks are still running after 30 seconds, warn the user and stop anyway
- Never force-kill — always use the graceful shutdown command

## Examples

User: `/stop`
→ "🛑 Shutting down..." → stop gateway

User: `/stop` (while task is running)
→ "⏳ Waiting for 1 active task to finish..." → wait → "🛑 Gateway stopped."
