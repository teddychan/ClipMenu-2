# Changelog

Developer-facing notes for ClipMenu. User-facing release notes live in
`app/Sources/ClipMenu/WhatsNewConfig.swift` (shown in the in-app What's New pane).

## Unreleased

## 2.20.1 — 2026-08-10

Housekeeping only — no user-facing change, and no What's New entry.

- **The committed `CFBundleVersion` was a stale `2.18.1`, two releases behind the
  marketing version beside it.** It is inert: every build path stamps
  `git rev-list --count HEAD` over it before the app is assembled —
  `app/scripts/run.sh`, `app/scripts/run-debug.sh`, `.github/workflows/release-mas.yml`,
  and the free channel inside `teddychan/dragon-release-ci`. So nothing shipped with
  the wrong build number; the problem was that the checked-in value *read* like a real
  version and invited someone to trust or "fix" it. Reset to `1`, the obvious inert
  placeholder the sibling Dragon repos use (dragon-kit's `sample-app/Info.plist`), so
  the file says "this gets overwritten" instead of naming a release.
- `CFBundleShortVersionString` 2.20.0 → 2.20.1. This is the only version the release
  tag is checked against (`assert_tag_matches_plist`), and it stays hand-maintained.

## 2.19.1 — 2026-08-07

Fixes from an engineering-standard audit of the clipboard, menu, and snippet
paths. Two were reachable from the Settings panes by typing a plausible number.

- **Data loss: a history size of `0` deleted the entire clipboard history.** The
  cap was passed unclamped into the trim query, where Core Data reads
  `fetchOffset = 0` as "select every row" (and `fetchLimit = 0` as "no limit") —
  so the next copy deleted every clip including the one just captured, with no
  warning and no recovery (history is not part of backup). A negative value made
  the fetch throw, which `try?` swallowed, silently disabling trimming for good.
  `ClipStore.maxHistorySize` now floors at 1.
- **Crash: a negative tool-tip length trapped on every menu build.**
  `clipToolTip` feeds the value to `String.prefix(_:)`, which traps on a negative
  count, so the app died on every status-item click until the pref was reset.
  Clamped in `MainMenuController.MenuPrefs`, beside the existing thumbnail clamp.
- **Lowering the history cap now applies immediately, after a confirmation.**
  `trim()` only ran inside `capture()`, so the menu hid the surplus clips while
  they stayed readable on disk until the next copy — lowering the cap to prune
  sensitive history gave a false sense of deletion, and raising it brought every
  clip back. New `ClipStore.enforceCapNow`; the alert names the exact count.
- **The numeric preference fields are bounded** (`PreferenceRanges`), replacing
  free-form text fields that accepted any integer. Settings and the onboarding
  wizard now share the constants instead of drifting (`1...999` vs unbounded).
- **Snippet edits no longer lose work silently.** All 12 mutation sites in the
  editor saved with `try? context.save()`; a failed write left the views showing
  the in-memory context while the work was gone at next launch. They route
  through one helper that raises a single persistent banner, localized in all 7
  languages.
- **The App menu and Uninstall pane read the app's real name.** They used a
  hardcoded `"ClipMenu 2"`, so a debug build labelled itself as the release app
  while acting on debug data. Now read from the bundle, with the literal kept as
  the `swift run` fallback.
- **19 comments cited a deleted `CLAUDE.md`.** Its invariants are published as
  `docs/design-invariants.md` and cited by section *name* — the numbers had
  already drifted, with several `§2` citations pointing at the wrong section.
- `scripts/run-debug.sh` stamps `(Debug)` onto the version and launches with
  `open -n`, so a debug build can't be mistaken for the release in a screenshot
  and LaunchServices can't resolve to a stale bundle from another checkout.
- **DragonKit 2.1.0 → 2.3.0** (`app/Package.swift`, `app/Package.resolved`),
  clearing conformance R10. Of the kit's three fixes only the failed-uninstall
  one reaches this app — it ships `UninstallSettingsPane`; it does not use
  `DragonSettingsStore` (so the settings-reset-on-upgrade bug never applied) or
  `DragonBackup` (so the malformed-restore fix never applied). No app code
  changes were needed.

## 2.19.0 — 2026-08-04

Uninstall left the status-item menu. DragonKit 2.0.0's `DragonAppMenu` no longer
takes an `onUninstall` handler, so the App-menu section is About · Check for
Updates… (direct build only) · Settings… · — · Quit. A rare destructive action
does not belong one click from Quit; it stays reachable as DragonKit's
`UninstallSettingsPane`, the last pane in Settings, which ClipMenu already ships.

- **DragonKit 1.5.0 → 2.0.0** (`app/Package.swift`, `app/Package.resolved`).
  Breaking only in the menu-builder signature described above.
- `MainMenuController` drops its `uninstall(_:)` action; the menu assertion in
  `MainMenuControllerCoverageTests` now checks Uninstall is *absent*, scoped to
  the App-menu tail so a clipboard entry above can't satisfy the match.
- What's New copy refreshed for this release in all 7 localizations.

## 2.17.11 — 2026-07-11

Maintenance release: test-coverage and internal quality only — no user-facing
behavior changes (the app is functionally identical to 2.17.10).

### Tests & coverage — phase 2 (SwiftUI + reorder + backup/restore)

Pushed coverage from the logic layer into the SwiftUI/UI layer and the
drag-reorder ("layout movement") and backup/restore code.

- **Test cases: 313 → 374** (+61), across **53 → 59** test files.
- **Line coverage: 39.3% → 74.2%** overall (region 45.8% → 67.3%, function 67.3%).
- **Backup & restore → 100%** (all in ClipMenu's `Premium/`, not DragonKit):
  `BackupManager`, `BackupModels`, `BackupFolder` at 100%; `FolderBackupStore` 97%,
  `BackupRetention` 97%, `SnippetSnapshot` 93%, `SettingsSidecar` 95%. Restore
  error paths (undecodable payload, newer-schema rejection) and the restore UI
  (`RestoreVersionsView`) are covered.
- **Layout movement (drag-reorder):** extracted the snippet editor's reorder /
  index-renumber arithmetic out of `SnippetEditorView` into a pure, testable
  `ManualReorder` helper (`moved` / `afterRemoving` / `nextIndex`) — now **100%**;
  `SnippetEditorView` 0% → 59%.
- **SwiftUI panes via ViewInspector** (new test-only dependency, `ClipMenuTests`
  target only — never linked by the app): `PreferencesPanes` 0% → 76% (incl. the
  Sync & Backup pane), `OnboardingView` 0% → 88%, `MainMenuController` 61%.
- **Test execution is now serial.** Run the suite with `app/scripts/test.sh`
  (wraps `swift test --arch arm64 --no-parallel`). Several suites exercise
  process-global singletons (`NSPasteboard.general`, the shared UserDefaults backup
  baseline); Swift Testing's default cross-suite parallelism races them, and
  `.serialized` only orders tests within a suite — so the canonical run is serial.
- Still not unit-testable (need a running `NSApplication` / real system state):
  window `show()` hosting (`SettingsWindowController`, the window controllers), the
  `@main`/AppDelegate lifecycle (`App`), Carbon hot-key registration, and the
  fire-and-forget backup `Task` against the live store — these are the bulk of the
  remaining ~26%.

### Tests & coverage

Expanded the unit-test suite (Swift Testing) to lock down the app's logic layer.

- **Test cases: 147 → 313** (+166), across **29 → 53** test files. All green.
- **Line coverage: 18.8% → 39.3%** overall (region 21.6% → 37.6%), measured with
  `swift test --enable-code-coverage` + `xcrun llvm-cov`.
- The **non-UI logic layer is now near-exhaustively covered** — 24 source files at
  ≥93%, including:
  - `ClipCapture` (clipboard capture, dedup, trim, thumbnails) 49% → **98.8%**
  - `ActionStore` 65% → **97.9%**, `ScriptableClip` 62% → **97.8%**
  - `ActionEngine` 8% → **93.2%**, `BuiltInActions`, `Paster`, `HotKeyCenter` (pure logic)
  - `MainMenuController` (NSMenu building) 5.8% → **60.9%**
  - `Thumbnailer`, `MenuIconCache`, `StatusItemController` 0% → **95–98%**
  - Backup/premium stack (`BackupManager`, `FolderBackupStore`, `BackupRetention`,
    `BackupModels`, `BackupScheduler`) and `StoreMigration`
  - `HistoryExport`, `Updater`, `AboutConfig`, `WhatsNewConfig`, `DistributionChannel` at **100%**
- New characterization tests assert real behavior only (menu trees, pasteboard
  contents, dedup/thumbnail derivation, Codable round-trips, Carbon⇄Cocoa key
  formatting); no source code was modified.

**Coverage ceiling (documented, not a gap to chase):** the remaining ~60% is code
a headless `swift test` process cannot execute — pure SwiftUI view bodies
(`PreferencesPanes`, `SnippetEditorView`, `OnboardingView`), the `@main`/AppDelegate
lifecycle and window `show()` hosting, and system side-effects (live `CGEvent`
paste, Carbon hot-key registration, cursor-anchored pop-ups). Covering the SwiftUI
views would need the ViewInspector test dependency (~65% ceiling); true ~90% would
require an XCUITest UI-automation target driving a launched app.
