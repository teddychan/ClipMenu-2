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

    @MainActor
    static var content: AboutContent {
        AboutContent(
            appName: AppInfo.displayName,
            versionString: DragonAbout.versionString(),
            // Assembled by the kit so the format matches every other Dragon app;
            // mirrors LICENSE.
            copyright: DragonAbout.copyright(
                original: (years: "2008–2014", holder: "Naotaka Morimoto"),
                years: "2026",
                holder: "Teddy Chan"
            ),
            websiteURL: websiteURL,
            supportURL: issuesURL,
            license: "MIT",
            // Third-party notices. Ungated, unlike `attributions` below: the four
            // bundled JavaScript libraries behind the Actions transforms ship in
            // every build, so the page has something to say even where Sparkle
            // does not ship. Trailing slash — it is the path Pages serves, so the
            // row does not point at a redirect.
            licensesURL: URL(string: "https://www.dragonapp.com/clipmenu-2/licenses/")!,
            originalWork: OriginalWork(name: "ClipMenu", author: "Naotaka Morimoto"),
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
