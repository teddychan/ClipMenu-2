import Foundation

/// Central registry of `UserDefaults` / `@AppStorage` keys, so a key is spelled
/// in exactly one place. Referencing a constant is compiler-checked, which
/// catches the silent "typo creates a brand-new key" class of bug that bare
/// string literals invite.
///
/// Each constant's identifier is deliberately identical to its string value, so
/// the mapping is obvious at every call site. Keys are grouped by the Settings
/// tab they belong to, mirroring `SettingsSync.syncedKeys`.
enum PreferenceKeys {
    // General
    static let appLanguage = "appLanguage"
    static let inputPasteCommand = "inputPasteCommand"
    static let reorderClipsAfterPasting = "reorderClipsAfterPasting"
    static let maxHistorySize = "maxHistorySize"
    static let timeInterval = "timeInterval"
    static let saveHistoryOnQuit = "saveHistoryOnQuit"
    static let showStatusItem = "showStatusItem"
    static let exportHistoryAsSingleFile = "exportHistoryAsSingleFile"
    static let tagOfSeparatorForExportHistoryToFile = "tagOfSeparatorForExportHistoryToFile"

    // Menu
    static let numberOfItemsPlaceInline = "numberOfItemsPlaceInline"
    static let numberOfItemsPlaceInsideFolder = "numberOfItemsPlaceInsideFolder"
    static let maxMenuItemTitleLength = "maxMenuItemTitleLength"
    static let menuItemsAreMarkedWithNumbers = "menuItemsAreMarkedWithNumbers"
    static let addNumericKeyEquivalents = "addNumericKeyEquivalents"
    static let showLabelsInMenu = "showLabelsInMenu"
    static let addClearHistoryMenuItem = "addClearHistoryMenuItem"
    static let showAlertBeforeClearHistory = "showAlertBeforeClearHistory"
    static let showToolTipOnMenuItem = "showToolTipOnMenuItem"
    static let maxLengthOfToolTipKey = "maxLengthOfToolTipKey"
    static let changeFontSize = "changeFontSize"
    static let howToChangeFontSize = "howToChangeFontSize"
    static let selectedFontSize = "selectedFontSize"
    static let showImageInTheMenu = "showImageInTheMenu"
    /// Longest side (px) the image thumbnail is fit into in the menu; the user
    /// picks how big thumbnails are. Aspect-preserving, never upscaled, clamped
    /// to 16…256 (256 = the stored thumbnail's resolution, Thumbnailer).
    /// Replaces the legacy separate `thumbnailWidth`/`thumbnailHeight` box.
    static let thumbnailMaxSize = "thumbnailMaxSize"
    static let showIconInTheMenu = "showIconInTheMenu"
    static let menuIconSize = "menuIconSize"
    static let positionOfSnippets = "positionOfSnippets"
    static let groupSnippetsInFolder = "groupSnippetsInFolder"

    // Type
    static let storeTypes = "storeTypes"

    // Action
    static let enableAction = "enableAction"
    static let invokeActionImmediately = "invokeActionImmediately"
    static let controlClickBehavior = "controlClickBehavior"
    static let shiftClickBehavior = "shiftClickBehavior"
    static let optionClickBehavior = "optionClickBehavior"
    static let commandClickBehavior = "commandClickBehavior"

    // Shortcuts + exclusions
    static let hotKeys = "hotKeys"
    static let excludeApps = "excludeApps"

    // Machine-local (intentionally NOT synced across Macs).
    static let loginItem = "loginItem"
    static let suppressAlertForLoginItem = "suppressAlertForLoginItem"
    /// Security-scoped bookmark (Data) of the user-chosen backup folder, and a
    /// display path for the UI. The folder can live in Dropbox / iCloud Drive /
    /// Google Drive to sync backups across Macs (no iCloud entitlement needed).
    static let backupFolderBookmark = "backupFolderBookmark"
    static let backupFolderPath = "backupFolderPath"
    /// Whether to back up automatically when quitting (default true).
    static let automaticBackupEnabled = "automaticBackupEnabled"
    /// Last-selected Settings tab, so reopening Settings returns to it. The
    /// "About <App>" menu item overrides this to the About tab.
    static let settingsSelectedTab = "settingsSelectedTab"
    /// Local cache of the last snippet-backup time (a `Date`). NOT authoritative —
    /// the backup folder is the source of truth; this is an offline/perf fallback.
    static let lastSnippetBackupDate = "lastSnippetBackupDate"
    /// Local cache of the last snippet-backup content hash (offline fallback only).
    static let lastSnippetBackupHash = "lastSnippetBackupHash"

    /// First-run setup wizard. `onboardingCompleted` gates *whether* the wizard
    /// shows (set once it's finished or deliberately closed); `onboardingStep` is
    /// the resume point (the current step index), written on every Back/Continue so
    /// a mid-wizard relaunch — e.g. a language change — reopens on the same step.
    /// Per-device, so not synced.
    static let onboardingCompleted = "onboardingCompleted"
    static let onboardingStep = "onboardingStep"
}

/// Accepted ranges for the free-form numeric preference fields.
///
/// The fields are plain text fields, so without a bound the user can store a value
/// the rest of the app can't express: `maxHistorySize` of 0 made the trim query
/// delete the entire history, and a negative tool-tip length crashed every menu
/// build. The consuming code keeps its own defensive clamp as a safety net for
/// values stored before these existed (and for anything arriving via the synced
/// settings sidecar); these ranges are the *policy* — what a person is allowed to
/// type — and live here so the Settings pane and the onboarding wizard can't drift
/// apart, as they had (`1...999` there vs unbounded here).
///
/// 2000 is the shared ceiling: past it these settings stop being meaningful long
/// before they become dangerous.
enum PreferenceRanges {
    /// Clips to keep. At least 1 — see `ClipStore.maxHistorySize` for why 0 is not
    /// "keep nothing" to the fetch descriptors it feeds.
    static let maxHistorySize = 1...2000

    /// Clips shown directly in the menu before the rest go into overflow folders.
    /// **0 is legitimate and is the default** (AppController.m:146-147): it means
    /// "none inline, group everything into folders". This is the one field whose
    /// floor is 0 rather than 1 — forcing 1 would silently change the out-of-box
    /// menu layout for anyone who merely opens this pane.
    static let numberOfItemsPlaceInline = 0...2000

    /// Clips per overflow folder; a folder holding none can't be navigated.
    static let numberOfItemsPlaceInsideFolder = 1...2000

    /// Characters of a clip's text shown as its menu title. Values under 3 all
    /// render as the bare "..." ellipsis, since `trimTitle` reserves those 3.
    static let maxMenuItemTitleLength = 1...2000

    /// Characters of a clip's text shown in its hover tool tip. Floored at 100
    /// because a tool tip is there to preview more of the clip than the (much
    /// shorter) menu title already shows — a tiny cap makes the feature pointless,
    /// and "off" is what the "Show tool tip on a menu item" toggle is for.
    static let maxLengthOfToolTip = 100...2000

    /// Longest side (px) of the menu image thumbnail. Deliberately NOT the shared
    /// 1...2000: 16 is the smallest visible thumbnail and 256 is the stored
    /// thumbnail's own resolution (`Thumbnailer.storedMaxPixelSize`) — asking for
    /// more forces a decode from the multi-MB original on every menu open.
    static let thumbnailMaxSize = 16...256
}
