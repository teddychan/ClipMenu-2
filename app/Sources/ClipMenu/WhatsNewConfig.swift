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
            // read "ClipMenu modern rewrite.", a tagline in the slot macOS reserves for a legal
            // notice. The same defect class DragonKit records from yahoo-keykey-2, which shipped
            // `倉頡／簡易 輸入法` there.
            //
            // Narrow but observable, which is what earns `.fixed`: Finder's Get Info panel reads
            // this key, so a user can select ClipMenu.app, press ⌘I and see it. (The standard
            // AppKit About panel reads it too, but ClipMenu never opens one — its About is
            // DragonKit's settings pane.) 2.20.3 claimed `.fixed` on a comparably small surface.
            //
            // Deliberately NOT presented as walking back 2.20.6's "names one holder instead of
            // two". These are two different fields with two different jobs, and they are meant to
            // differ: the About pane's row is a presentation slot the kit fixes at one holder
            // (CONFORMANCE §R14), while this key is the bundle's legal notice and carries what
            // LICENSE carries. DragonKit says so outright — §R14 leaves `LICENSE`,
            // `NSHumanReadableCopyright` and the licences page out of scope, and ice-2 keeps both
            // holders in its Info.plist while rendering one in About.
            summary: L("A fix for the copyright notice: the one macOS shows in Finder's Get Info panel described the app instead of naming a copyright holder."),
            sections: [
                ChangeSection(kind: .fixed, entries: [
                    L("Finder's Get Info panel now shows ClipMenu's copyright holders instead of a one-line description of the app."),
                ]),
            ]
        )
    }
}
