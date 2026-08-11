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
            // `.fixed` with one entry: `NSHumanReadableCopyright` — the bundle's copyright notice —
            // read "ClipMenu modern rewrite.", a tagline in the slot macOS reserves for a copyright.
            // The same defect class DragonKit records from yahoo-keykey-2, which shipped
            // `倉頡／簡易 輸入法` there.
            //
            // Narrow but observable, which is what earns `.fixed`: Finder's Get Info panel reads
            // this key, so a user can select ClipMenu.app, press ⌘I and see it. (The standard
            // AppKit About panel reads it too, but ClipMenu never opens one — its About is
            // DragonKit's settings pane.) 2.20.3 claimed `.fixed` on a comparably small surface.
            //
            // The notes describe the END STATE, not this version's delta, and that is deliberate.
            // Three releases touched this one key in a few hours: 2.20.7 fixed the tagline but
            // named two holders, 2.20.8 dropped the second (#82), and 2.20.9 drops the word
            // "Copyright" so the value matches the About row byte for byte (#85). The pane shows
            // only the current version's notes, and nearly every user arrives from 2.20.6, so the
            // entry names what they will actually see change — the tagline replaced by a
            // copyright — rather than narrating three steps none of them observed. The summary key
            // is reused verbatim from 2.20.7 because it is still exactly true; only the entry is
            // restated. 2.20.5 set the precedent for reuse when a key still says the right thing.
            //
            // Why one holder, and why this exact string: `NSHumanReadableCopyright` is an OPTIONAL
            // Apple key that no licence names, so it is presentation, and the same argument that
            // fixes About's row at one holder (CONFORMANCE §R14) reaches it. `LICENSE` is where
            // MIT's grant lives and it still names both. All five Dragon apps now carry the
            // identical value in both places — ice-2 was the last holdout and gave way in 2.14.7,
            // its GPL-3.0 §4 obligation being carried by its LICENSE and bundled acknowledgements
            // rather than by an optional display key.
            summary: L("A fix for the copyright notice: the one macOS shows in Finder's Get Info panel described the app instead of naming a copyright holder."),
            sections: [
                ChangeSection(kind: .fixed, entries: [
                    L("Finder's Get Info panel now shows ClipMenu's copyright, the same line the About pane shows."),
                ]),
            ]
        )
    }
}
