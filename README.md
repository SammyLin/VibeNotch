# VibeNotch — MVP

Turn your MacBook notch into an AI Agent monitoring panel.

![VibeNotch Status](https://img.shields.io/badge/Status-MVP-orange)

## Architecture

```
Claude Code
  └─ claude-code-hook.sh        (hook subscriber)
       └─ emitter.py             (socket client)
            └─ Unix Domain Socket: /tmp/notch-agent.sock
                 └─ NotchAgent.app (Swift) ← notch panel UI
```

## Status Emoji

| Emoji | Meaning |
|-------|---------|
| 😐 | Idle |
| 🤔 | Thinking (processing your prompt) |
| ⚙️ | Working (tool in use / subagent running) |
| ⏳ | Waiting |
| ✅ | Completed |
| ❌ | Error |

## MVP Setup (Step 1 — Hook + Emitter)

### 1. Build the Swift App (optional for now)

The Swift app is not ready yet. For MVP, you can test the hook independently:

```bash
# Test the emitter directly
echo '{"event": "test"}' | python3 hook/emitter.py
# Should print: [VibeNotch] → test → idle
```

### 2. Install the Claude Code Hook

```bash
# Make scripts executable
chmod +x hook/claude-code-hook.sh
chmod +x hook/emitter.py

# Add to ~/.claude/settings.json:
```

```json
{
  "hooks": [
    {
      "matcher": {
        "event": "*"
      },
      "command": "/Users/openbot/otta.workspace/notch-agent/hook/claude-code-hook.sh"
    }
  ]
}
```

Or use the CLI flag per session:

```bash
claude --hook-script ~/otta.workspace/notch-agent/hook/claude-code-hook.sh
```

### 3. Start NotchAgent (Swift App)

Once the Swift socket server is implemented:

```bash
cd NotchAgent
make build
open NotchAgent.xcodeproj
# Build and run from Xcode
```

The app will:
1. Create `/tmp/notch-agent.sock`
2. Listen for events from the hook
3. Display status in the notch area

## Hook Events → Status Mapping

| Claude Code Hook Event | Notch Status |
|------------------------|-------------|
| `SessionStart` | ⚙️ Working |
| `UserPromptSubmit` | 🤔 Thinking |
| `Stop` | 😐 Idle |
| `StopFailure` | ❌ Error |
| `SubagentStart` | ⚙️ Working |
| `SubagentStop` | 😐 Idle |
| `TaskCompleted` | ✅ Completed |
| `PostToolUse` | ⚙️ Working |
| `PostToolUseFailure` | ❌ Error |
| `TeammateIdle` | 😐 Idle |

## Files

```
notch-agent/
├── hook/
│   ├── claude-code-hook.sh   # Claude Code hook entrypoint
│   └── emitter.py            # Python UDS socket client
├── NotchAgent/               # Swift app (future)
│   ├── App/
│   ├── Views/
│   ├── Models/
│   └── Services/
├── project.yml               # XcodeGen config
└── Makefile
```

## TODO

- [ ] Implement Swift `SocketServer.swift` UDS listener
- [ ] Build SwiftUI notch panel view
- [ ] Hook up socket events → Swift UI updates
- [ ] macOS app signing + distribution
