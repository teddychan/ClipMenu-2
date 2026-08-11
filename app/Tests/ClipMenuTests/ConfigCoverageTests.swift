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

    /// One copyright holder, ClipMenu 2's own. Pinned as a literal because the value is the
    /// claim: this asserted an upstream holder too until DragonKit 4.0.0, which ClipMenu had no
    /// standing to do — it reimplements the original rather than reusing its source. The
    /// lineage moved to `originalWork`, asserted below in both of the rows it now fills.
    @Test func contentSingleSourcesNameAndCopyright() {
        let content = AboutConfig.content
        #expect(content.appName == AppInfo.displayName)
        #expect(content.copyright == "© 2026 Teddy Chan")
        #expect(content.versionString == DragonAbout.versionString())
        #expect(!content.versionString.isEmpty)
    }

    @Test func contentHasWebsiteSupportOriginalAndLicensesLinks() {
        let links = AboutConfig.content.linkRows
        #expect(links.count == 4)

        let website = links[0]
        #expect(website.detail == "dragonapp.com/clipmenu-2")
        #expect(website.systemImage == "globe")
        #expect(website.url.absoluteString == "https://www.dragonapp.com/clipmenu-2/")

        let support = links[1]
        #expect(support.detail == "teddychan/clipmenu-2")
        #expect(support.systemImage == "lifepreserver")
        #expect(support.url.absoluteString == "https://github.com/teddychan/clipmenu-2/issues")

        // The row this suite used to assert was ABSENT. `originalWork` carried a name and an
        // author but no URL — optional until DragonKit 4.0.0 — so the pane credited "Based on
        // ClipMenu by Naotaka Morimoto" and linked to ClipMenu nowhere. Asserting its presence
        // here, beside the credit below, is what keeps the two halves from parting again.
        let original = links[2]
        #expect(original.detail == "naotaka/ClipMenu")
        #expect(original.systemImage == "heart")
        #expect(original.url.absoluteString == "https://github.com/naotaka/ClipMenu")

        // The detail is DERIVED from the URL by the kit, never typed beside it — asserting the
        // derived string here is what proves the trailing slash does not leak into the row.
        let licenses = links[3]
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

    /// 2.20.5's notes: a single `changed` section with one entry. The release is the DragonKit pin
    /// moving 3.3.0 → 3.4.0 and nothing else, so the entry claims the framework bump and stops —
    /// About's "Built with · DragonKit v3.4.0" row is the only part of it a user can see. Same
    /// shape as 2.20.4, and reached the same way: `.changed` because nothing was broken, one entry
    /// because there is exactly one thing to say. It reuses 2.20.2's entry key, that release having
    /// been the same bump, so the shape holding steady here is the claim staying honest rather than
    /// the notes going unrevised — the file's own diff is what the release gate checks.
    ///
    /// 2.20.4 pinned this shape for moving SUFeedURL off the marketing site onto the app's own
    /// repository, which no user can observe — updates keep arriving, from the same signing key, at
    /// the same cadence — so `.changed` was the honest kind there too.
    ///
    /// 2.20.3 was the opposite case and pinned `[.fixed]`: exactly one thing in it was observable,
    /// uninstalling clearing Homebrew's receipt. 2.20.2 pinned `[.changed]` for this same reason —
    /// everything it fixed was reachable only from a local Debug build, so claiming a fix a user
    /// could look for would have been false. Pinned per release alongside the WhatsNewConfig copy
    /// itself — the section shape IS the claim, so updating the notes has to update this, which is
    /// the point. The release gate checks that the notes CHANGED; this checks that they changed to
    /// what was meant.
    @Test func contentIsASingleChangedSection() {
        let sections = WhatsNewConfig.content.sections
        #expect(sections.count == 1)
        #expect(sections.map(\.kind) == [.changed])
        #expect(sections.map(\.entries.count) == [1])
        for entry in sections.flatMap(\.entries) {
            #expect(!entry.isEmpty)
        }
    }
}
