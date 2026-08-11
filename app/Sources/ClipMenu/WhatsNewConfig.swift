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
            // Maintenance-only, like 2.20.2 and for the same reason: 2.20.4 moves where the app
            // LOOKS for updates, and a user cannot observe that. Updates keep arriving, from the
            // same signing key, at the same cadence. `.changed` and not `.fixed` — nothing was
            // broken; the feed simply stopped living in the marketing site's repository, so an
            // outage or a rejected change there can no longer interfere with update delivery.
            // Reuses 2.20.2's summary key rather than writing a near-identical seventh
            // translation of the same sentence.
            summary: L("A maintenance release: internal updates only, with no changes to how ClipMenu works."),
            sections: [
                ChangeSection(kind: .changed, entries: [
                    L("ClipMenu now checks for updates from its own repository rather than the website."),
                ]),
            ]
        )
    }
}
