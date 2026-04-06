# NotchAgent

Turn MacBook notch into an AI Agent monitoring panel.

## Project Goal
Display real-time status of AI coding agents (Claude Code, Gemini, Codex) in the notch area of MacBook Pro. Receives hook events via Unix Domain Socket.

## Architecture
- **Swift 5.9+**, macOS 14 Sonoma+
- **SwiftUI** for views, **AppKit** for window management (NSPanel)
- **XcodeGen** for project generation (`project.yml`)
- Entry point: `NotchAgent/App/main.swift`

## Key Directories
- `App/` — App entry point and lifecycle
- `Views/` — SwiftUI views (NotchPanelView, StatusIndicator)
- `Models/` — Data models (AgentSession)
- `Services/` — Socket server and background services

## Agent Colors
- Claude Code: `#D97757` (orange)
- Gemini: `#4285F4` (blue)
- Codex: `#10A37F` (green)

## Conventions
- Use SwiftUI for all UI components
- Use AppKit (NSPanel) for window positioning over notch
- Detect notch via `NSScreen.main?.safeAreaInsets.top`
- Fallback: top-center floating bar on non-notch Macs
- Target idle: RAM < 50MB, CPU < 1%

## Commands
```bash
make generate  # xcodegen generate
make build     # swift build
make open      # open .xcodeproj in Xcode
make clean     # clean build artifacts
```
