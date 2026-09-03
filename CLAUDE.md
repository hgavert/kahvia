# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Kahvia** — A macOS menu bar app to toggle `/usr/bin/caffeinate` with 3 states. Built as a Swift Package with a build script that assembles a proper `.app` bundle.

## States

| State | Flags | Meaning |
|-------|-------|---------|
| Off | none | `caffeinate` not running — Mac may sleep |
| On | (no flags) | Default caffeinate — blocks idle sleep only |
| Display | `-d` | Blocks display sleep — stops when display goes to sleep |

## Architecture

**Swift Package** with sources in `Sources/`:

```
caffeinate_menu_bar_app/
├── Info.plist               ┌── .app bundle metadata (LSUIElement = true)
├── build.sh                 └── compile + bundle + ad-hoc sign → Kahvia.app
├── Package.swift
├── Sources/
│   ├── main.swift           # @main entry point, MenuBarExtra scene
│   └── CaffeinateManager.swift   # ObservableObject: state, process management, persistence
└── README.md
```

### `main.swift`

- `@main struct KahviaApp: App`
- `@StateObject private var manager = CaffeinateManager()`
- **Menu bar icon**: custom coffee-mug artwork per state, loaded from bundled
  vector PDFs as template images (`Resources/Icons/cup-*.pdf`)
  - Off → `cup-off` (empty mug outline)
  - On → `cup-on` (filled mug + steam)
  - Display → `cup-display` (mug + steam inside a screen frame)
- **Menu dropdown**: status text at top, divider, an inline `Picker` listing all
  three modes (checkmark on the active one), divider, Quit

### `CaffeinateManager.swift`

`@MainActor final class CaffeinateManager: ObservableObject` managing:

- **State**: `@Published var activeState: AppState` — enum with 3 cases (`.off`, `.on`, `.display`)
- **Process**: private `Process?` — starts/stops caffeinate, detects natural exit via `terminationHandler`
- **Always launches Off**: state is never persisted/restored, so the app never silently
  holds a sleep assertion on startup
- **State-driven process management**: `activeState`'s `didSet` starts/switches/stops
  caffeinate on every change; old process is terminated before launching new one
- **Restart logic**: when switching states while running, old process is terminated before launching new one
- **Cleanup**: `-w <self-pid>` ensures caffeinate exits when the app quits

### Icon mapping

| State | Icon asset | Menu item label |
|-------|-----------|-----------------|
| Off | `cup-off.pdf` (empty mug) | "Off — sleep allowed" |
| On | `cup-on.pdf` (filled mug + steam) | "On — keep awake" |
| Display | `cup-display.pdf` (mug in screen) | "Display — keep display on (-d)" |

Icons are black-on-transparent template PDFs in `Resources/Icons/` (SVG source +
PNG @1x/@2x also kept there); `build.sh` copies the PDFs into the app bundle's
`Contents/Resources`. To regrow them from SVG, re-run the CoreGraphics renderer.

## Build & Run

```bash
# Build and create .app bundle (produces Kahvia.app)
./build.sh

# Run
open Kahvia.app
```

Build script uses `swift build -c release`, copies the binary into the `.app` bundle structure, embeds `Info.plist`, and ad-hoc signs.

## What's intentionally excluded

- Timers / duration limits
- Login at startup
- Custom icon assets (SF Symbols only)
- Distribution / CI — personal use only

## Verification

1. `./build.sh` — builds cleanly, produces `Kahvia.app`
2. `open Kahvia.app` — icon appears in menu bar with correct initial state
3. Click menu bar icon → dropdown shows status text and all three modes (checkmark on active)
4. Selecting a mode switches directly to it (Off / On / Display), starting/stopping caffeinate accordingly
5. While "On" or "Display", `pmset -g assertions` shows caffeinate holding assertion
6. Menu bar icon changes to reflect current state
7. Quit and relaunch — always starts in Off (state is not persisted)
8. Quit app while caffeinate is running — process is terminated cleanly
