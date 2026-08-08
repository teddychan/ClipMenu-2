import Testing
import DragonKit
@testable import ClipMenu

// Characterization tests for the two static content providers that feed
// DragonKit's shared About and What's New panes. They are pure value builders,
// so the tests pin the exact links, credits, and release-note shape the app
// ships. Both are @MainActor because they call DragonKit's MainActor-isolated
// L()/DragonAbout helpers.

@MainActor
@Suite struct AboutConfigCoverageTests {

    @Test func contentSingleSourcesNameAndCopyright() {
        let content = AboutConfig.content
        #expect(content.appName == AppInfo.displayName)
        #expect(content.copyright == "© 2008–2014 Naotaka Morimoto · © 2026 Teddy Chan")
        #expect(content.versionString == DragonAbout.versionString())
        #expect(!content.versionString.isEmpty)
    }

    @Test func contentHasWebsiteAndSupportLinks() {
        let links = AboutConfig.content.linkRows
        #expect(links.count == 2)

        let website = links[0]
        #expect(website.detail == "dragonapp.com/clipmenu-2")
        #expect(website.systemImage == "globe")
        #expect(website.url.absoluteString == "https://www.dragonapp.com/clipmenu-2/")

        let support = links[1]
        #expect(support.detail == "teddychan/clipmenu-2")
        #expect(support.systemImage == "lifepreserver")
        #expect(support.url.absoluteString == "https://github.com/teddychan/clipmenu-2/issues")
    }

    /// The Website row must address the canonical `/clipmenu-2/` page, not the
    /// `/clipmenu/` redirect stub the app linked before DragonKit 3.
    @Test func websiteIsTheCanonicalPageNotTheStub() {
        #expect(AboutConfig.content.websiteMatchesSupportRepo)
    }

    /// The canon order the kit assembles: Created by → Based on → Built with →
    /// License. `test.sh` runs Sparkle-free (`CLIPMENU_SPARKLE=`), which is also the
    /// Mac App Store build's shape, so no attribution row follows these four; the
    /// Developer ID build appends "Sparkle · MIT".
    @Test func contentCreditsAuthorsAndLicense() {
        let credits = AboutConfig.content.creditRows
        #expect(credits.count == 4)
        #expect(credits.map(\.value) == [
            "Teddy Chan",
            "ClipMenu by Naotaka Morimoto",
            "DragonKit v\(DragonKitVersion.current)",
            "MIT",
        ])
    }
}

@MainActor
@Suite struct WhatsNewConfigCoverageTests {

    /// The version is no longer passed by the app: it defaults to the bundle and the
    /// kit adds the "v", so the pane can't drift from CFBundleShortVersionString.
    /// Pins the shape, not a literal — outside a configured bundle the kit falls back
    /// to "1.0.0" where `AppInfo.version` falls back to "—".
    @Test func versionIsPrefixedFromTheBundle() {
        let shown = WhatsNewConfig.content.displayVersion
        #expect(shown.hasPrefix("v"))
        #expect(!shown.hasPrefix("vv"))
        #expect(shown.count > 1)
    }

    @Test func contentHasDateAndSummary() {
        let content = WhatsNewConfig.content
        #expect(content.date == "2026-08-08")
        #expect(!content.summary.isEmpty)
    }

    /// 2.20.0's notes: two fixes (the untranslated About labels, the Website link
    /// pointing at the redirect stub) then one change (About crediting the original
    /// ClipMenu and the DragonKit version). Pinned per release alongside the
    /// WhatsNewConfig copy itself.
    @Test func contentHasAFixedThenChangedSection() {
        let sections = WhatsNewConfig.content.sections
        #expect(sections.count == 2)
        #expect(sections.map(\.kind) == [.fixed, .changed])
        #expect(sections.map(\.entries.count) == [2, 1])
        for entry in sections.flatMap(\.entries) {
            #expect(!entry.isEmpty)
        }
    }
}
