import Foundation
import DragonKit

/// ClipMenu's content for DragonKit's shared About pane. The kit owns every row
/// title, SF Symbol and ordering (`AboutContent` assembles them, `AboutSettingsPane`
/// renders them); the app supplies only URLs and proper nouns. The version is
/// single-sourced from Info.plist via `DragonAbout` — never hardcoded.
enum AboutConfig {
    /// The canonical marketing page. Not `/clipmenu/`, which is a `<meta refresh>`
    /// stub whose `rel=canonical` points here — the kit's `websiteMatchesSupportRepo`
    /// checks this path against the support URL's repo name, so the stub fails it.
    private static let websiteURL = URL(string: "https://www.dragonapp.com/clipmenu-2/")!
    /// Support link goes straight to the GitHub issues page.
    private static let issuesURL = URL(string: "https://github.com/teddychan/clipmenu-2/issues")!
    /// The upstream project ClipMenu 2 reimplements. The same repository LICENSE and the
    /// README cite — one string, so the pane cannot cite a different fork or casing than
    /// the notices do.
    private static let originalProjectURL = URL(string: "https://github.com/naotaka/ClipMenu")!

    @MainActor
    static var content: AboutContent {
        AboutContent(
            appName: AppInfo.displayName,
            versionString: DragonAbout.versionString(),
            // Assembled by the kit so the format matches every other Dragon app.
            //
            // One holder — ClipMenu 2's own. This passed an `original:` pair until DragonKit
            // 4.0.0 and rendered a second, upstream copyright beside it; only ClipMenu and
            // ice-2 did that, so two of five About panes carried a line the other three did
            // not. Consistency is the smaller half of the reason. ClipMenu 2 is an
            // independent Swift 6 reimplementation that reuses none of the original's
            // source, so asserting Naotaka Morimoto's copyright over *this* binary states
            // something the app's own notices contradict. Nor is the lineage lost by
            // dropping it: it is carried twice below, by the `Original project` link and the
            // `Based on` credit, and the original's licence text travels on the licences
            // page. LICENSE keeps both holders — it is the licence document, and its upstream
            // grant is what the MIT terms require; this row is not that document.
            copyright: DragonAbout.copyright(years: "2026", holder: "Teddy Chan"),
            websiteURL: websiteURL,
            supportURL: issuesURL,
            // Third-party notices. Ungated, unlike `attributions` below: the four
            // bundled JavaScript libraries behind the Actions transforms ship in
            // every build, so the page has something to say even where Sparkle
            // does not ship. Trailing slash — it is the path Pages serves, so the
            // row does not point at a redirect.
            licensesURL: URL(string: "https://www.dragonapp.com/clipmenu-2/licenses/")!,
            license: "MIT",
            // Fills two slots at once: the `Original project` link row and the `Based on`
            // credit. The URL was a separate optional `originalProjectURL:` parameter until
            // DragonKit 4.0.0 and ClipMenu never passed it, so the pane credited "Based on
            // ClipMenu by Naotaka Morimoto" while linking to ClipMenu nowhere — found by
            // comparing all five Dragon apps' panes side by side, ice-2 having the identical
            // gap. 4.0.0 folded the URL into `OriginalWork` precisely so half of it can no
            // longer be supplied.
            originalWork: OriginalWork(
                name: "ClipMenu",
                author: "Naotaka Morimoto",
                url: originalProjectURL
            ),
            attributions: attributions
        )
    }

    /// Sparkle ships only in the Developer ID build (DragonKitUpdates, gated by the
    /// SPARKLE flag). The Mac App Store build links DragonKit core, bundles no
    /// third-party code, and so must not claim it does.
    private static var attributions: [Attribution] {
        #if SPARKLE
        [Attribution(name: "Sparkle", license: "MIT")]
        #else
        []
        #endif
    }
}
