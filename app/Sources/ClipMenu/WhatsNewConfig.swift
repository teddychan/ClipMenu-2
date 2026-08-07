import Foundation
import DragonKit

/// ClipMenu's release notes for DragonKit's shared What's New pane. Update per
/// release alongside the CFBundleShortVersionString bump in Info.plist.
enum WhatsNewConfig {
    @MainActor
    static var content: WhatsNewContent {
        WhatsNewContent(
            version: "v\(AppInfo.version)",
            date: "2026-08-07",
            summary: L("Fixes a bug that could erase your clipboard history, and a crash when opening the menu."),
            sections: [
                ChangeSection(kind: .fixed, entries: [
                    L("Your clipboard history could be erased after setting the history size to 0."),
                    L("ClipMenu could crash every time the menu opened after a negative tool tip length was set."),
                    L("Edits in the snippet editor could be lost without warning if they couldn't be saved."),
                ]),
                ChangeSection(kind: .changed, entries: [
                    L("Reducing the history size now asks first, then removes the older clips right away."),
                    L("Settings no longer accept sizes and lengths that don't work, such as 0 items."),
                ]),
            ]
        )
    }
}
