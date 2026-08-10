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
            date: "2026-08-11",
            // One entry, because one thing in 2.20.3 is observable. The other two changes
            // are release plumbing — the shared pipeline moved to a stricter tag gate, and
            // the Sparkle appcast now publishes to this repository as well as the marketing
            // site — and neither alters anything a user can see or do. Inventing a second
            // entry to make the pane look fuller is what the release gate's "say what
            // changed, or say plainly that nothing user-facing did" exists to stop.
            summary: L("A small fix for anyone who installed ClipMenu with Homebrew."),
            sections: [
                ChangeSection(kind: .fixed, entries: [
                    L("Uninstalling from Settings now clears Homebrew's record of ClipMenu too, so installing it again with Homebrew works instead of being refused as already installed."),
                ]),
            ]
        )
    }
}
