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

    /// 2.20.6's notes: a single `fixed` section with two entries. The first release since 2.20.3 to
    /// claim `.fixed`, and it earns it — two rows of the About pane were wrong, and both are things
    /// a user can open the pane and look at: the `Original project` link was absent while `Based on`
    /// credited the project it should have linked, and the copyright named an upstream holder this
    /// binary reuses no source from.
    ///
    /// Two entries, not three. The DragonKit pin moving 3.4.0 → 4.0.0 changes About's "Built with"
    /// row as well, but 4.0.0 is the *vehicle* for these two fixes — it makes the pane's slots
    /// compile-enforced, which is what stops either defect returning — so listing it beside them
    /// would report the means twice and bury the effect.
    ///
    /// 2.20.5 pinned `[.changed]` with one entry for the opposite case: the DragonKit pin moving
    /// 3.3.0 → 3.4.0 WAS the whole release, About's "Built with" row its only observable part, so
    /// the bump was the honest claim there and it reused 2.20.2's entry key rather than adding an
    /// eighth near-identical sentence to seven .lproj files. 2.20.4 pinned that shape too, for
    /// moving SUFeedURL onto the app's own repository — updates keep arriving, from the same
    /// signing key, at the same cadence, so no user can observe it.
    ///
    /// 2.20.3 was the last `[.fixed]`: exactly one thing in it was observable, uninstalling
    /// clearing Homebrew's receipt. 2.20.2 pinned `[.changed]` because everything it fixed was
    /// reachable only from a local Debug build, so claiming a fix a user could look for would have
    /// been false. Pinned per release alongside the WhatsNewConfig copy itself — the section shape
    /// IS the claim, so updating the notes has to update this, which is the point. The release gate
    /// checks that the notes CHANGED; this checks that they changed to what was meant.
    @Test func contentIsASingleFixedSection() {
        let sections = WhatsNewConfig.content.sections
        #expect(sections.count == 1)
        #expect(sections.map(\.kind) == [.fixed])
        #expect(sections.map(\.entries.count) == [2])
        for entry in sections.flatMap(\.entries) {
            #expect(!entry.isEmpty)
        }
    }
}
