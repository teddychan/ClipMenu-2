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
            date: "2026-08-10",
            // Maintenance-only, and said so rather than dressed up. Everything 2.20.2
            // fixes — the actions.plist collision, the debug build's identity and its
            // updater — is only reachable from a local Debug build running beside the
            // installed copy, so there is nothing here a user of the release build can
            // observe. Inventing a feature entry to fill the pane would be a lie the
            // release gate exists to catch.
            summary: L("A maintenance release: internal updates only, with no changes to how ClipMenu works."),
            sections: [
                ChangeSection(kind: .changed, entries: [
                    L("Updated the shared Dragon toolkit that ClipMenu is built with."),
                ]),
            ]
        )
    }
}
