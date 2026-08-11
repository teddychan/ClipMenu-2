# Changelog

Developer-facing notes for ClipMenu. User-facing release notes live in
`app/Sources/ClipMenu/WhatsNewConfig.swift` (shown in the in-app What's New pane).

## Unreleased

## 2.20.5 — 2026-08-11

Maintenance only, and unusually literally so: the only thing that changed about the shipped
app is which version of the shared kit it links, and the only place that is visible is the
About pane.

- **DragonKit 3.3.0 → 3.4.0 is the whole release.** `app/Package.swift`'s pin moved, so
  About's Credits now reads "Built with · DragonKit v3.4.0" instead of v3.3.0. That row is
  the single observable difference; no behaviour, setting, shortcut or stored file changes.

  Both of 3.4.0's new parameters are defaulted — `LanguagePicker(languages:onChange:)` —
  so the bump is source-compatible and nothing here had to be adapted for it. ClipMenu
  calls `LanguagePicker()` in `PreferencesPanes.swift` and deliberately keeps the default
  language list: the argument was added for ice-2, which has translated its own strings
  into Simplified Chinese only and whose picker therefore offered six languages it could
  not deliver, whereas ClipMenu ships all seven the kit does. The picker it renders is
  byte-for-byte the one 2.20.4 rendered.

  The What's New notes reuse 2.20.2's summary *and* entry keys rather than adding an eighth
  near-identical sentence across seven `.lproj` files. 2.20.2 was this same release —
  DragonKit 3.2.0 → 3.3.0, nothing user-facing — and
  "Updated the shared Dragon toolkit that ClipMenu is built with." was already the vetted
  translation of it. `2.20.4`'s SUFeedURL sentence stays in the strings files: it describes
  a release users can still be upgrading from.
- **No release-plumbing change, despite `release.yml` moving.** The other commit since
  v2.20.4 was comment-only — it replaced the mirror's unmeasurable retirement condition
  ("when no supported version still reads the site") with a real trigger, the next MINOR
  release. `appcast_mirror_repo` therefore stays through this patch and goes away at
  2.21.0; the parsed workflow is identical to v2.20.4's.

## 2.20.4 — 2026-08-11

Maintenance only from a user's point of view. Step 2 of 2 in giving ClipMenu its own
Sparkle update feed.

- **`SUFeedURL` now points at this repository** —
  `raw.githubusercontent.com/teddychan/clipmenu-2/main/docs/clipmenu-2/appcast.xml` —
  instead of `www.dragonapp.com/clipmenu-2/appcast.xml`. dragon-kit's
  `docs/MAC-APP-RELEASE-LIFECYCLE.md`: "Sparkle appcasts are update infrastructure, not
  marketing content. Each app should host its production appcast in its own repository so
  an outage, permission problem, or rejected change in the marketing-site repository
  cannot interfere with update delivery."

  2.20.3 was step 1: it set `appcast_repo` to this repo and `appcast_mirror_repo` to the
  site, which is what first created `docs/clipmenu-2/appcast.xml` here. The order matters
  in one direction only — flipping `SUFeedURL` before a release had populated the new
  location would have pointed every install at a 404. Verified before this change: both
  copies exist and are byte-identical (sha256 `8c56943…`), and the new URL serves 200.

  `appcast_mirror_repo` deliberately stays. Every copy at 2.20.3 or earlier still reads
  the site, and it is the release after which no supported version does that may drop it.
- **The Mac App Store workflow no longer owns a `mas-v*` tag series.** It is dispatch-only
  and takes an existing public `vX.Y.Z`, per the same spec's "one public tag namespace per
  repository". Nothing about the shipped app changes; the nine historical `mas-v*` tags stay
  for provenance.

## 2.20.3 — 2026-08-11

One user-visible fix; the other two changes are release plumbing.

- **Uninstalling left Homebrew's records claiming ClipMenu was still installed.**
  `UninstallConfig` never passed `homebrewCask`, so the in-app uninstall moved the app
  to the Trash and stopped there. Homebrew never watches the filesystem, so its receipt
  still said the cask was installed and `Caskroom/clipmenu-2/<version>/ClipMenu 2.app`
  was a dangling symlink; `brew install --cask clipmenu-2` then refused outright —
  "already installed" — for an app that wasn't there, with nothing pointing at
  `brew reinstall` as the way out. ice-2 and dragon-sample-app already passed the token.

  Passing it flat would have been worse: `brew uninstall --cask --force` is not
  bundle-scoped, and `Casks/clipmenu-2.rb` carries
  `uninstall quit: "com.dragonapp.clipmenu-2"`, so from the Debug build it would have
  quit and deleted the installed release. Three builds must issue nothing — the Debug
  build and a build with no bundle id (both caught by the kit's fail-closed
  `UninstallConfig.caskToken`), and the Mac App Store build, which no bundle-id
  comparison can see because it is sandboxed but carries the same id. That one is
  excluded by `DistributionChannel`, this app's existing runtime channel check.
- **The release moved to `dragon-release-ci@v6`, with `whats_new_path`.** v6's tag gate
  accepts only an exact `vX.Y.Z` and requires a What's New source that has changed since
  the preceding tag. Both halves had to land in one commit: passing `whats_new_path` to
  v5 fails at startup, and omitting it on v6 fails the gate.
- **The Sparkle appcast now publishes to this repository as well as the marketing site.**
  Step 1 of 2 in giving the app its own update feed, per dragon-kit's
  `docs/MAC-APP-RELEASE-LIFECYCLE.md`. `SUFeedURL` still points at the site — which is
  still being written — so nothing changes for any existing install; this release is what
  first populates `docs/clipmenu-2/appcast.xml` here. Step 2 moves `SUFeedURL` to it.

## 2.20.2 — 2026-08-10

Maintenance only from a user's point of view: every defect below is reachable
solely from a local Debug build running beside the installed release, so the
What's New entry says maintenance-only rather than inventing a fix to claim.

- **`scripts/run-debug.sh` appended ` (Debug)` to `CFBundleShortVersionString`.**
  That field is the sole source of truth for the app's semantic version and the one
  string the release tag is checked against (`assert_tag_matches_plist`); a channel
  label inside it makes the version non-numeric. dragon-kit's
  `docs/MAC-APP-RELEASE-LIFECYCLE.md` forbids it outright. The script now asserts
  `X.Y.Z` and stamps `DragonBuildChannel = Debug`, which DragonKit 3.3.0 renders as
  `v2.20.2 Debug (76)` — so a screenshot still can't be mistaken for the release
  build, which was the suffix's original purpose.
- **The debug bundle could have checked the production appcast.** It inherited the
  release's `SUFeedURL`, so an update would have replaced the debug build with the
  public one. The script now deletes `SUFeedURL` and sets `SUEnableAutomaticChecks`
  false: Sparkle refuses to start without a feed, `DragonUpdater` leaves its
  `SPUUpdater` nil, and every route goes inert at the data layer. `UpdaterUI`
  additionally reports unsupported on the Debug channel, so the menu item is absent
  rather than inert. The Updates *pane* is deliberately still built — with no feed it
  renders inert, and the sidebar then matches the release build pane for pane.
- **`ActionStore.saveURL` wrote `actions.plist` into the release's folder.** It
  hardcoded `Application Support/ClipMenu` while everything else routes through the
  debug-aware `AppStore.folder`, so a debug build edited the installed release's
  action set — or wrote the defaults over it on first launch. It was also the path
  `SettingsWindowController.uninstallConfig` already declared, so uninstall was
  cleaning a file nothing wrote. Identical for a release build; no migration.
- DragonKit 3.2.0 → 3.3.0 (`DragonAbout.buildChannel` / `isDebugBuild`, and the
  channel-aware `versionString()`).

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
