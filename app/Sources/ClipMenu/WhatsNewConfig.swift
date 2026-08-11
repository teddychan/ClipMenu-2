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
            // Maintenance-only, and 2.20.5 is 2.20.2 again: the DragonKit pin moves 3.3.0 → 3.4.0
            // and nothing else in the app changes. The one thing a user can observe is About's
            // "Built with · DragonKit v3.4.0" row, so the entry claims exactly that and stops.
            // `.changed` and not `.fixed` — nothing was broken. 3.4.0's own addition is a
            // `languages` argument on the shared LanguagePicker, added for ice-2, which ships one
            // translation and would otherwise offer six it cannot deliver; ClipMenu is translated
            // into all seven languages the kit ships, so it keeps the default and the picker is
            // identical. Reuses 2.20.2's summary AND entry keys — that release was this same
            // DragonKit bump, so the copy already exists in seven languages and writing an eighth
            // near-identical translation of it would be the drift these notes avoid.
            summary: L("A maintenance release: internal updates only, with no changes to how ClipMenu works."),
            sections: [
                ChangeSection(kind: .changed, entries: [
                    L("Updated the shared Dragon toolkit that ClipMenu is built with."),
                ]),
            ]
        )
    }
}
