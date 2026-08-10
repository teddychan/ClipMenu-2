import Foundation
import DragonKit

#if SPARKLE
import DragonKitUpdates
#endif

/// Channel-agnostic facade over DragonKit's Sparkle wrapper, so UI code and the
/// app delegate compile in **both** builds with no `#if` scattered through them.
/// In the Sparkle/direct build these forward to a shared `DragonUpdater` (which
/// also backs the Updates settings pane); in the Mac App Store build — where
/// DragonKitUpdates/Sparkle are not linked at all — they are inert.
@MainActor
enum UpdaterUI {
    #if SPARKLE
    /// The app's single updater instance. `UpdatesSettingsPane` binds its
    /// auto-check/auto-download toggles; the menu-bar "Check for Updates…" item
    /// goes through `checkNow()`.
    static let updater = DragonUpdater()
    #endif

    /// Whether in-app updates exist in this build. True only when Sparkle is
    /// compiled in (the direct / Developer ID build) **and** this is not a local
    /// Debug build; the Mac App Store build returns false and shows no update UI.
    ///
    /// scripts/run-debug.sh links Sparkle on purpose, so the debug build compiles
    /// the same product the release ships — but a debug bundle keeps the release's
    /// SUFeedURL, so an actual check would offer the PRODUCTION appcast and
    /// "updating" would replace the debug build with the release one. The lifecycle
    /// spec makes that flat: a Debug build "never reads or publishes the production
    /// appcast". Gating here rather than at each call site reuses the mechanism the
    /// Mac App Store build already proves: the menu item is passed `nil` and is
    /// absent (MainMenuController.addAppMenuSection), and the Updates pane is not
    /// built (SettingsWindowController.settingsPanes) — an inert item would just
    /// look broken. `DragonUpdater` creates `SPUUpdater` lazily on first property
    /// access, so "nothing touches it" is exactly what keeps Sparkle from starting.
    static var isSupported: Bool {
        #if SPARKLE
        return !DragonAbout.isDebugBuild()
        #else
        return false
        #endif
    }

    /// Start the updater (scheduled background checks). Call once at launch.
    /// `DragonUpdater` creates Sparkle's `SPUStandardUpdaterController` lazily on
    /// first use, so touch it here to begin the scheduled-check timer.
    static func start() {
        #if SPARKLE
        guard isSupported else { return }
        _ = updater.canCheckForUpdates
        #endif
    }

    /// The user's "automatically check for updates" preference. Sparkle persists
    /// this itself (SUEnableAutomaticChecks), so it is the single source of truth.
    /// No-op getter/setter when unsupported.
    static var automaticallyChecksForUpdates: Bool {
        get {
            #if SPARKLE
            guard isSupported else { return false }
            return updater.automaticallyChecksForUpdates
            #else
            return false
            #endif
        }
        set {
            #if SPARKLE
            guard isSupported else { return }
            updater.automaticallyChecksForUpdates = newValue
            #endif
        }
    }

    /// Manual "Check Now" (menu bar item): shows Sparkle's standard UI.
    static func checkNow() {
        #if SPARKLE
        guard isSupported else { return }
        updater.checkForUpdates()
        #endif
    }
}
