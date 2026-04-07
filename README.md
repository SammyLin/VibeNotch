# VibeNotch 🦞

A macOS notch companion that shows Claude Code status using emoji in your MacBook's notch area.

Forked from [Notchi](https://github.com/sk-ruban/notchi) — simplified to use emoji instead of pixel sprites.

## What it does

- Shows Claude Code status as emoji in the MacBook notch area
- 🦞 Idle — ⚙️ Working — 🤔 Thinking — ⏳ Waiting — ✅ Completed — ❌ Error
- Analyzes conversation sentiment to show emotions (happy, sad, neutral)
- Click to expand and see session time and usage quota
- Supports multiple concurrent Claude Code sessions
- Sound effects for events (optional, auto-muted when terminal is focused)

## Requirements

- macOS 15.0+ (Sequoia)
- MacBook with notch
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed

## How it works

```
Claude Code --> Hooks (shell scripts) --> Unix Socket --> Event Parser --> State Machine --> Emoji Display
```

VibeNotch registers a shell script hook with Claude Code on launch. When Claude Code emits events (tool use, thinking, prompts, session start/end), the hook script sends JSON payloads to a Unix socket (`/tmp/vibenotch.sock`). The app parses these events, runs them through a state machine, and displays the current state as an emoji in the notch.

Each Claude Code session gets its own emoji on the expanded panel. Clicking expands the notch panel to show a live activity feed, session info, and API usage stats.

## Building

1. Clone the repo
2. Open `notchi/notchi.xcodeproj` in Xcode
3. Set your Development Team in Signing & Capabilities
4. Build and run (⌘R)

## Hook Installation

The app automatically installs hooks into `~/.claude/settings.json` on first launch. You can also manually trigger installation from the Settings panel.

The hook script is installed at `~/.claude/hooks/vibenotch-hook.sh`.

## Credits

- Original [Notchi](https://github.com/sk-ruban/notchi) by [@sk-ruban](https://github.com/sk-ruban)
- VibeNotch fork by [@SammyLin](https://github.com/SammyLin)

## License

GPL-3.0-only. See [LICENSE](LICENSE).
