#!/usr/bin/env python3
"""Emitter for VibeNotch — sends Claude Code hook events to the NotchAgent UDS socket."""

import json
import socket
import sys
from datetime import datetime

SOCKET_PATH = "/tmp/notch-agent.sock"

AGENT = "claude-code"

# Map hook event types → VibeNotch status emoji
STATUS_MAP = {
    "thinking": "🤔",
    "working": "⚙️",
    "idle": "😐",
    "completed": "✅",
    "error": "❌",
}

# Claude Code hook event types that map to our statuses
# See: https://code.claude.com/docs/en/hooks
CLAUDE_EVENT_STATUS = {
    "SessionStart": "working",
    "UserPromptSubmit": "thinking",
    "Stop": "idle",
    "StopFailure": "error",
    "SubagentStart": "working",
    "SubagentStop": "idle",
    "TaskCompleted": "completed",
    "PostToolUse": "working",
    "PostToolUseFailure": "error",
    "TeammateIdle": "idle",
}


def get_status(event_type: str) -> str:
    return CLAUDE_EVENT_STATUS.get(event_type, "idle")


def send_event(event_type: str, data: dict | None = None) -> bool:
    """Send event to NotchAgent via Unix Domain Socket. Returns True on success."""
    status = get_status(event_type)
    payload = {
        "event": status,
        "agent": AGENT,
        "timestamp": int(datetime.now().timestamp()),
        "hook_event": event_type,
        "data": data or {},
    }

    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(1)  # Don't block if socket isn't ready
        sock.connect(SOCKET_PATH)
        sock.sendall((json.dumps(payload) + "\n").encode("utf-8"))
        sock.close()
        print(f"[VibeNotch] → {event_type} → {status}", file=sys.stderr)
        return True
    except (socket.error, socket.timeout, ConnectionRefusedError, FileNotFoundError):
        # Socket not ready — skip gracefully
        return False


if __name__ == "__main__":
    # Read JSON from stdin (Claude Code hook passes data this way)
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        # Fallback: use event type from argv if available
        event_type = sys.argv[1] if len(sys.argv) > 1 else "unknown"
        hook_input = {}

    event_type = hook_input.get("event", sys.argv[1] if len(sys.argv) > 1 else "unknown")
    send_event(event_type, hook_input)
