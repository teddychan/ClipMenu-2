import Foundation
import DragonKit

/// ClipMenu's release notes for DragonKit's shared What's New pane. Update per
/// release alongside the CFBundleShortVersionString bump in Info.plist.
enum WhatsNewConfig {
    @MainActor
    static var content: WhatsNewContent {
        WhatsNewContent(
            version: "v\(AppInfo.version)",
            date: "2026-08-04",
            summary: L("Uninstall has moved out of the menu-bar menu into Settings."),
            sections: [
                ChangeSection(kind: .removed, entries: [
                    L("Uninstall is no longer in the menu-bar menu, next to Quit."),
                ]),
                ChangeSection(kind: .changed, entries: [
                    L("Find it as the last pane in Settings, where it confirms before removing anything."),
                ]),
            ]
        )
    }
}
