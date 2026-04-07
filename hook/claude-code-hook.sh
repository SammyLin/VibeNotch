#!/bin/bash
# VibeNotch Claude Code Hook Script
# Subscribes to Claude Code hook events and emits them to NotchAgent via Unix Domain Socket.
#
# Setup:
#   1. Save this file somewhere, e.g. ~/notch-agent-hook.sh
#   2. Make it executable: chmod +x ~/notch-agent-hook.sh
#   3. Add to ~/.claude/settings.json:
#      {
#        "hooks": [
#          {
#            "matcher": { "event": "*" },
#            "command": "/path/to/claude-code-hook.sh"
#          }
#        ]
#      }
#   Or via CLI flag: claude --hook-script ~/notch-agent-hook.sh
#
# Events consumed: SessionStart, UserPromptSubmit, Stop, StopFailure,
#                  SubagentStart, SubagentStop, TaskCompleted, PostToolUse,
#                  PostToolUseFailure, TeammateIdle

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EMITTER="$SCRIPT_DIR/emitter.py"

# Claude Code passes the event type as the first argument
EVENT_TYPE="${1:-unknown}"

# Run the Python emitter, passing the event type and stdin
"$EMITTER" "$EVENT_TYPE" < /dev/stdin
