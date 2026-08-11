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
            // `.fixed`, and the first release since 2.20.3 that earns it: two rows of the About
            // pane were wrong, and both are things a user can open the pane and look at. New copy
            // rather than 2.20.2's reused keys — the last three releases had nothing observable to
            // report and said so; this one does.
            //
            // The DragonKit pin moving 3.4.0 → 4.0.0 is deliberately NOT a third entry, even
            // though About's "Built with" row changes with it. 4.0.0 is the vehicle for these two
            // fixes, not a separate claim: it makes the pane's slots compile-enforced, which is
            // what stops either defect returning. Listing the bump beside them would report the
            // means twice and bury the effect — and 2.20.5 already claimed a kit bump on its own,
            // because there it WAS the whole release.
            summary: L("A fix for the About pane: it now links the original ClipMenu project, and shows a single copyright holder."),
            sections: [
                ChangeSection(kind: .fixed, entries: [
                    L("The About pane now links the original ClipMenu project that ClipMenu 2 is based on."),
                    L("The About pane's copyright line now names one holder instead of two."),
                ]),
            ]
        )
    }
}
