#!/bin/bash
# Build + launch a LOCAL DEBUG build of ClipMenu with its OWN identity so it runs
# safely NEXT TO the installed release. Per dragon-mac-ops "Test / debug builds":
# the debug build gets bundle id com.dragonapp.clipmenu-2.debug and the name
# "ClipMenu 2 Debug", so it has its own TCC entry + UserDefaults domain and never
# fights the installed app's menu-bar/login-item instance.
#
# (clipmenu-2 is SwiftPM, not Xcode, so this adapts the skill's xcodebuild template
# to `swift build` + the same .app assembly as scripts/run.sh.)
#
# Usage:  ./scripts/run-debug.sh
set -euo pipefail
cd "$(dirname "$0")/.."            # package root (app/)

export CLIPMENU_SPARKLE=1         # include the Sparkle updater locally
swift build -c debug --arch arm64
BIN_PATH="$(swift build -c debug --arch arm64 --show-bin-path)"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Info.plist)"
MAJOR="${VERSION%%.*}"
APP_NAME="ClipMenu ${MAJOR} Debug"
DEBUG_ID="com.dragonapp.clipmenu-2.debug"
APP=".build/${APP_NAME}.app"

# Quit ONLY this debug instance (never the installed release).
pkill -f "${APP_NAME}.app/Contents/MacOS" 2>/dev/null || true
sleep 1
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_PATH/ClipMenu" "$APP/Contents/MacOS/ClipMenu"
cp Info.plist "$APP/Contents/Info.plist"

pb=/usr/libexec/PlistBuddy
"$pb" -c "Set :CFBundleIdentifier ${DEBUG_ID}" "$APP/Contents/Info.plist"
"$pb" -c "Set :CFBundleName ${APP_NAME}" "$APP/Contents/Info.plist"
"$pb" -c "Add :CFBundleDisplayName string ${APP_NAME}" "$APP/Contents/Info.plist" 2>/dev/null \
  || "$pb" -c "Set :CFBundleDisplayName ${APP_NAME}" "$APP/Contents/Info.plist"

# Build number = git commit count (monotonic); About shows "Version X (build)".
BUILD="$(git rev-list --count HEAD 2>/dev/null || echo "$VERSION")"
"$pb" -c "Set :CFBundleVersion ${BUILD}" "$APP/Contents/Info.plist"

# Commit timestamp (%cI) for About's version line; DragonAbout drops the timestamp
# when the key is absent rather than falling back to the executable's mtime.
COMMIT_DATE="$(git log -1 --format=%cI 2>/dev/null || true)"
if [ -n "$COMMIT_DATE" ]; then
    "$pb" -c "Set :DragonCommitDate ${COMMIT_DATE}" "$APP/Contents/Info.plist" 2>/dev/null \
      || "$pb" -c "Add :DragonCommitDate string ${COMMIT_DATE}" "$APP/Contents/Info.plist"
fi

# Mark the marketing version too, so a screenshot / About pane / log line can
# never be mistaken for the release build. The name alone isn't enough: bug
# reports quote the version, and without this it reads identically to release.
# Stamped here rather than in Info.plist so it can't drift on a version bump
# (this bundle's plist is re-copied from source on every run; the guard keeps the
# suffix idempotent anyway).
SHORT_VERSION="$("$pb" -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")"
case "$SHORT_VERSION" in
  *"(Debug)") ;;
  *) SHORT_VERSION="$SHORT_VERSION (Debug)"
     "$pb" -c "Set :CFBundleShortVersionString ${SHORT_VERSION}" "$APP/Contents/Info.plist" ;;
esac

cp AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

# All SwiftPM resource bundles: the app's own + DragonKit's localized strings.
for BUNDLE_PATH in "$BIN_PATH"/*.bundle; do
    [ -d "$BUNDLE_PATH" ] || continue
    BUNDLE_NAME="$(basename "$BUNDLE_PATH")"
    cp -R "$BUNDLE_PATH" "$APP/Contents/Resources/$BUNDLE_NAME"
    chmod -R u+w "$APP/Contents/Resources/$BUNDLE_NAME"
done
if [ -d "$BIN_PATH/Sparkle.framework" ]; then
    mkdir -p "$APP/Contents/Frameworks"
    cp -R "$BIN_PATH/Sparkle.framework" "$APP/Contents/Frameworks/Sparkle.framework"
    chmod -R u+w "$APP/Contents/Frameworks/Sparkle.framework"
fi

# Prefer the stable "ClipMenu Dev" identity (keeps the debug bundle's TCC grant
# across rebuilds); fall back to ad-hoc.
SIGN_IDENTITY="ClipMenu Dev"
if security find-identity -p codesigning 2>/dev/null | grep -q "$SIGN_IDENTITY"; then
    IDENTITY="$SIGN_IDENTITY"
    echo "Signing debug build with: $SIGN_IDENTITY"
else
    IDENTITY="-"
    echo "Ad-hoc signing — macOS re-prompts for permissions each rebuild."
fi
if [ -d "$APP/Contents/Frameworks/Sparkle.framework" ]; then
    codesign --force --deep --sign "$IDENTITY" "$APP/Contents/Frameworks/Sparkle.framework" 2>/dev/null || true
fi
codesign --force --deep --sign "$IDENTITY" "$APP" 2>/dev/null || true

echo "Assembled $APP (id ${DEBUG_ID})"
# -n opens the bundle at THIS exact path. A plain `open` (or `open -b`) lets
# LaunchServices resolve the debug id to whichever bundle it likes — including a
# stale build in another checkout — so you'd debug a binary you didn't just
# compile. It also parents the app to launchd, so it outlives this shell.
open -n "$APP"
echo "Launched ${APP_NAME} ${SHORT_VERSION} (build ${BUILD}) — runs next to the installed ClipMenu 2."
