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

    @Test func contentHasWebsiteSupportAndLicensesLinks() {
        let links = AboutConfig.content.linkRows
        #expect(links.count == 3)

        let website = links[0]
        #expect(website.detail == "dragonapp.com/clipmenu-2")
        #expect(website.systemImage == "globe")
        #expect(website.url.absoluteString == "https://www.dragonapp.com/clipmenu-2/")

        let support = links[1]
        #expect(support.detail == "teddychan/clipmenu-2")
        #expect(support.systemImage == "lifepreserver")
        #expect(support.url.absoluteString == "https://github.com/teddychan/clipmenu-2/issues")

        // No "Original project" row between Support and this one: `originalWork` carries a
        // name and author but no URL, so the kit emits it as a credit, not a link.
        //
        // The detail is DERIVED from the URL by the kit, never typed beside it — asserting the
        // derived string here is what proves the trailing slash does not leak into the row.
        let licenses = links[2]
        #expect(licenses.detail == "dragonapp.com/clipmenu-2/licenses")
        #expect(licenses.systemImage == "doc.text")
        #expect(licenses.url.absoluteString == "https://www.dragonapp.com/clipmenu-2/licenses/")
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
        #expect(content.date == "2026-08-11")
        #expect(!content.summary.isEmpty)
    }

    /// 2.20.3's notes: a single `fixed` section with one entry, because exactly one thing in
    /// the release is observable — uninstalling now clears Homebrew's receipt, so reinstalling
    /// with brew works instead of being refused. The other two changes are release plumbing (the
    /// stricter tag gate, and the appcast publishing here as well as to the marketing site) and
    /// alter nothing a user can see or do.
    ///
    /// 2.20.2 was the opposite case and pinned `[.changed]` for it: everything that release fixed
    /// was reachable only from a local Debug build, so claiming a fix a user could look for would
    /// have been false. Pinned per release alongside the WhatsNewConfig copy itself — the section
    /// shape IS the claim, so updating the notes has to update this, which is the point. The
    /// release gate checks that the notes CHANGED; this checks that they changed to what was meant.
    @Test func contentIsASingleFixedSection() {
        let sections = WhatsNewConfig.content.sections
        #expect(sections.count == 1)
        #expect(sections.map(\.kind) == [.fixed])
        #expect(sections.map(\.entries.count) == [1])
        for entry in sections.flatMap(\.entries) {
            #expect(!entry.isEmpty)
        }
    }
}
