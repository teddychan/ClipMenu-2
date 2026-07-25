# ClipMenu 2

A modern macOS clipboard-history menu-bar app, written in Swift 6. It lives in
`app/` as a SwiftPM executable that runs as a menu-bar agent (no Dock icon).

## Features
- Clipboard history shown in a menu popped at the cursor or from the menu bar.
- Text snippets organized in folders.
- JavaScript text "Actions" (case, trim, HTML, Base64, hashing, Japanese
  conversions, and more).
- Image thumbnails in the menu, numbered items, and tooltips.
- Global hotkeys (Carbon) and paste synthesis into the frontmost app
  (requires Accessibility permission).
- Settings window (General / Menu / Type / Action / Shortcuts), persisted via
  `UserDefaults`; history and snippets stored via SwiftData.

## Installation
macOS 26 (Tahoe) or later on Apple Silicon.

### Homebrew (recommended)
```bash
brew install --cask teddychan/tap/clipmenu-2
```
Upgrade later with `brew upgrade --cask clipmenu-2`, or remove it with
`brew uninstall --zap --cask clipmenu-2`.

### Direct download
Download `ClipMenu-2-vX.Y.Z.zip` from the
[latest release](https://github.com/teddychan/clipmenu-2/releases/latest),
unzip it, and drag `ClipMenu 2.app` into `/Applications`. Builds are
Developer ID-signed and notarized, and update themselves via Sparkle.

### Mac App Store
[ClipMenu 2 on the Mac App Store](https://apps.apple.com/us/app/clipmenu-2/id6775685878?mt=12)
— free. The App Store build is sandboxed and updates through the App Store
instead of Sparkle; everything else matches the direct download.

### Build from source
See [Build & run](#build--run) below.

## Requirements (building from source)
- macOS 26 or 27 on Apple Silicon — the app ships a single arm64 build.
- A Swift 6 toolchain (Xcode 26+ or the matching Command Line Tools).

## Build & run
```bash
cd app
swift build
./scripts/run.sh        # assembles a .app bundle and launches it
```
Use `scripts/run.sh` rather than `swift run`: it builds, assembles
`.build/ClipMenu.app` (an `LSUIElement` agent), code-signs it, and launches it.
The status-bar icon and agent behavior only work from inside a `.app` bundle.

### First-run notes (Accessibility & signing)
- Pasting into the frontmost app needs Accessibility (TCC) permission — grant
  the app under System Settings ▸ Privacy & Security ▸ Accessibility.
- To keep that grant across rebuilds, create a stable self-signed
  "ClipMenu Dev" code-signing certificate (Keychain Access ▸ Certificate
  Assistant). Otherwise `run.sh` ad-hoc signs and the grant resets each build.

## Tests
```bash
cd app && swift test
```

## Project layout
- `app/` — the Swift app: `Sources/`, `Tests/`, bundled `Resources/`, and `scripts/`.

## Fun fact
My first clipboard mangaer is CLCL
https://nakka.com/soft/clcl/index_eng.html#google_vignette

<img width="600" height="411" alt="image" src="https://github.com/user-attachments/assets/11cdd6d1-329f-40da-8127-76decbbba41f" />


## Releasing
Maintainers: releases are automated in GitHub Actions. Pushing a `vX.Y.Z` tag
builds, signs (Developer ID), notarizes, and publishes the GitHub Release, the
Sparkle appcast, and the Homebrew cask; pushing a `mas-vX.Y.Z` tag builds and
uploads the Mac App Store package. See `.github/workflows/release.yml` and
`.github/workflows/release-mas.yml`.

## License
MIT — see [LICENSE](LICENSE).

## Credits
Based on the original [ClipMenu](https://github.com/naotaka/ClipMenu) by
Naotaka Morimoto, used under the MIT License.
