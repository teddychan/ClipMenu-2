import Foundation
import DragonKit

/// ClipMenu's release notes for DragonKit's shared What's New pane. Update per
/// release alongside the CFBundleShortVersionString bump in Info.plist.
enum WhatsNewConfig {
    @MainActor
    static var content: WhatsNewContent {
        WhatsNewContent(
            // Version omitted on purpose: it defaults to CFBundleShortVersionString
            // and the kit adds the "v". The pane tracks the current build's notes.
            date: "2026-08-08",
            summary: L("The About pane is now fully translated, and its links point where they should."),
            sections: [
                ChangeSection(kind: .fixed, entries: [
                    L("Several labels in the About pane stayed in English when ClipMenu was set to another language."),
                    L("The About pane's Website link opened a redirect page instead of ClipMenu's own page."),
                ]),
                ChangeSection(kind: .changed, entries: [
                    L("About now credits the original ClipMenu and shows which version of the shared Dragon toolkit the app was built with."),
                ]),
            ]
        )
    }
}
