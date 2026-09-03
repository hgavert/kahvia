#!/bin/bash
set -euo pipefail

APP_NAME="Kahvia"
APP_BUNDLE="${APP_NAME}.app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Building ${APP_NAME} (release)…"
swift build -c release

echo "==> Creating ${APP_BUNDLE}…"
rm -rf "$APP_BUNDLE"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
cp ".build/release/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"
cp "Info.plist" "${APP_BUNDLE}/Contents/"

# Bundle custom menu bar icons (vector PDFs, loaded as template images)
cp Resources/Icons/*.pdf "${APP_BUNDLE}/Contents/Resources/"

# Bundle app icon (Finder/Applications/Dock icon)
cp Resources/Icons/AppIcon.icns "${APP_BUNDLE}/Contents/Resources/"

echo "==> Ad-hoc code signing…"
codesign --force --sign - "$APP_BUNDLE"

echo "==> Done! Run with:  open ${APP_BUNDLE}"
