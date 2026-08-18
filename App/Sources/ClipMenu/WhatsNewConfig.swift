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
            date: "2026-08-18",
            // Maintenance-only, and 2.20.10 is 2.20.5 again — the same shape for the same reason.
            // Two things changed since 2.20.9 and neither is a feature: the DragonKit pin moves
            // 4.0.0 → 4.1.0 (#88), and `app/` was renamed to `App/` so the bundle inputs sit where
            // CONFORMANCE §R16 puts them (#87). The rename touched 107 Swift files and changed no
            // behaviour at all — it moved paths, not code — so it is developer-facing and belongs
            // in CHANGELOG.md, which is what that file is for. Inventing a feature entry to fill
            // the pane would be the lie the release gate exists to catch (2.20.2 refused the same
            // temptation).
            //
            // The one thing a user can observe is About's "Built with · DragonKit v4.1.0" row, so
            // the entry claims exactly that and stops. `.changed` and not `.fixed` — nothing here
            // was broken. 4.1.0's own content is a §R16 conformance rule and a rewritten changelog
            // in the kit's own repository; no shared pane, string or public signature moved, so
            // every ClipMenu surface the kit owns renders identically to 2.20.9's.
            //
            // Reuses 2.20.2's summary AND entry keys, exactly as 2.20.5 did: those releases were
            // this same maintenance shape, the copy already exists in all seven languages, and a
            // near-identical eighth translation of a sentence that is already true is the drift
            // these notes avoid. So no new key enters the seven `.lproj` files this release, and
            // the gate on this file still moves, because the date and the section did.
            summary: L("A maintenance release: internal updates only, with no changes to how ClipMenu works."),
            sections: [
                ChangeSection(kind: .changed, entries: [
                    L("Updated the shared Dragon toolkit that ClipMenu is built with."),
                ]),
            ]
        )
    }
}
