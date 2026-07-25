import Foundation
import DragonKit

/// ClipMenu's release notes for DragonKit's shared What's New pane. Update per
/// release alongside the CFBundleShortVersionString bump in Info.plist.
enum WhatsNewConfig {
    @MainActor
    static var content: WhatsNewContent {
        WhatsNewContent(
            version: "v\(AppInfo.version)",
            date: "2026-07-25",
            summary: L("Maintenance release."),
            sections: [
                ChangeSection(kind: .changed, entries: [
                    L("Nothing changed inside the app. ClipMenu 2 is now also on the Mac App Store, and the install instructions cover all three ways to get it: the App Store, Homebrew, and a direct download."),
                ]),
            ]
        )
    }
}
