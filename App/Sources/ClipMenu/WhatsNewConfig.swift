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
            // 2.21.0 is the first ClipMenu release with NO sections at all, and the summary alone
            // is the whole of the notes. One thing changed since 2.20.10 and it is a publish
            // destination: `release.yml` stopped passing `appcast_mirror_repo`, so the Sparkle
            // appcast now goes only to this repository (#92). That is the last appcast mirror in
            // the Dragon fleet — ice-2 retired its at v2.15.0, yahoo-keykey-2 at v2.12.0.
            //
            // A user cannot observe it, in the strict sense that no code in the shipped app is
            // different: `SUFeedURL` moved to the app-owned URL back in 2.20.4, and the mirror has
            // only ever been a second copy of a feed nothing has read since. So there is no honest
            // entry to write. 2.20.10's entry — "Updated the shared Dragon toolkit…" — would be
            // FALSE here, because the DragonKit pin does not move this release, and reusing it to
            // keep the familiar one-section shape is exactly the lie the gate exists to catch
            // (2.20.2 refused the same temptation from the other direction).
            //
            // Empty is a supported shape, not a workaround. dragon-release-ci's tag-gate.sh check 6
            // takes an explicit maintenance-only statement in place of entries, and
            // whats-new-export.py calls that case legitimate in as many words; the gate on this
            // file still moves, because the notes lost a section. The summary key is reused verbatim
            // from 2.20.2 — it is still exactly true and already exists in all seven `.lproj` files,
            // so no new key enters this release, and it carries the word the gate greps for.
            //
            // Why a minor for an invisible change: the mirror could not be dropped on a 2.20.x
            // patch. Copies still at 2.20.3 or older read the marketing site and only the site, and
            // the site is GitHub Pages, which exposes no per-path traffic — so "when the last
            // reader stops reading" is unobservable and a minor was chosen on 2026-08-11 as the
            // measurable substitute. The full reasoning is in release.yml beside the removal.
            summary: L("A maintenance release: internal updates only, with no changes to how ClipMenu works.")
        )
    }
}
