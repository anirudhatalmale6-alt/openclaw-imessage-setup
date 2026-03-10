---
metadata:
  openclaw:
    emoji: "🚀"
    bins:
      - bash
---

# Task Runner (/run)

## Description

Execute arbitrary shell commands on the local machine when the user sends `/run <command>`.
This skill is the core "remote control" for the Mac — it lets the user trigger any shell command
from their phone via iMessage or Telegram.

## When to activate

Activate when the user message starts with `/run` followed by a command string.

## Behavior

1. Parse the command after `/run` — everything after the space is the shell command.
2. Execute the command using `bash -c "<command>"` in the user's home directory.
3. Capture both stdout and stderr.
4. If the command succeeds (exit code 0), reply with:
   - ✅ Command executed successfully
   - The first 500 characters of stdout (if any output)
5. If the command fails (non-zero exit code), reply with:
   - ❌ Command failed (exit code: X)
   - The first 500 characters of stderr
6. If the command takes longer than 30 seconds, reply with a "still running..." update.

## Safety rules

- NEVER execute commands that contain `rm -rf /`, `mkfs`, `dd if=`, or `diskutil erase`
- NEVER execute commands that modify system files in /System or /Library
- If a command looks destructive, ask the user to confirm before executing
- Log every command to `~/.openclaw/logs/task-runner.log` with timestamp

## Examples

User: `/run echo "Hello World"`
→ Execute `echo "Hello World"`, reply with output "Hello World"

User: `/run open -a Safari`
→ Opens Safari, reply with "✅ Safari opened"

User: `/run ls ~/Desktop`
→ Lists Desktop contents, reply with the file listing

User: `/run python3 script.py`
→ Runs the Python script, reply with its output

User: `/run brew update`
→ Runs Homebrew update, reply with update results
