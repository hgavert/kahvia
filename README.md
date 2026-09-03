# Kahvia

A tiny macOS menu bar app to toggle `/usr/bin/caffeinate` with 3 states.

## Why

The point is to not have to open a terminal and run `caffeinate` every time
you want to keep your Mac awake — just click the menu bar icon instead.

Most external monitors cut power to the display cable once they go to sleep,
and losing that signal makes a MacBook think its lid is effectively closed,
so it switches to battery power even while plugged in. If you don't want
that, use the **Display** mode to keep the display itself on. The display can
still be locked (`⌃⌘Q` / lock screen) while in this mode — locking doesn't
put it to sleep.

Closing the laptop lid always forces sleep, no matter which mode is active —
`caffeinate` can't override that. Keep the lid open (or use an external
display in clamshell mode) if you want the Mac to stay awake.

## States

| State | Flags | Meaning |
|-------|-------|---------|
| Off | none | Mac may sleep |
| On | (default) | Blocks idle sleep |
| Display | `-d` | Blocks display sleep — stops when display goes to sleep |

## Requirements

- macOS 13+
- Xcode command-line tools (`swift` available)

## Build

```bash
# Build .app bundle (compile + bundle + ad-hoc sign)
./build.sh

# The script produces Kahvia.app with Info.plist (LSUIElement=true)
```

The build script runs `swift build -c release`, assembles a proper `.app` bundle structure with `Info.plist`, and ad-hoc signs.

## Run

```bash
open Kahvia.app
```

1. Run `Kahvia` — an icon appears in the menu bar.
2. Click the icon to pick a mode from the dropdown: Off, On, or Display.
3. The icon changes per state.
4. Quit app while caffeinate is running — the process stops cleanly (via `-w <pid>`).

## Design decisions

- No timers, no login-at-startup, no custom assets.
- Process auto-terminates when the app quits (`-w` flag).
- Ad-hoc signed so Gatekeeper won't block launch.
