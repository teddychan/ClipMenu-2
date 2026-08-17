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
    /// claim: this asserted an upstream holder too until DragonKit 4.0.0. The lineage moved to
    /// `originalWork`, asserted below in both of the rows it now fills.
    ///
    /// The reason is a presentation rule and NOT a claim about who holds the copyright — this
    /// comment argued the latter until the `NSHumanReadableCopyright` fix, that ClipMenu had no
    /// standing to name Naotaka Morimoto because it reimplements the original rather than reusing
    /// its source. DragonKit tried the same reasoning and retracted it (dragon-kit #63); ClipMenu's
    /// own `LICENSE` names two holders outright, so the app's notices contradicted it. What
    /// CONFORMANCE §R14 actually fixes is a row in a settings pane, and it leaves `LICENSE`,
    /// `NSHumanReadableCopyright` and the licences page alone.
    ///
    /// The bundle's `NSHumanReadableCopyright` is now this exact string, byte for byte, and so is
    /// every other Dragon app's. That is a separate decision rather than §R14 reaching the key:
    /// the key is an optional Apple one that no licence names, so it is presentation, and the same
    /// argument that settled this row settles it. `LICENSE` is where the MIT grant lives and it
    /// still names both holders; the upstream project is credited by `originalWork` below.
    ///
    /// ice-2 was the last holdout and gave way in its 2.14.7. It is a git fork carrying Jordan
    /// Baird's actual source under GPL-3.0 — where ClipMenu 2 reuses none of Naotaka Morimoto's —
    /// and it kept both holders in its plist on the reasoning that §4 makes that key the binary's
    /// notice. §4 is really carried by its `LICENSE` and bundled acknowledgements, both of which
    /// still name him; an optional display key was never what discharged it.
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

    /// 2.20.8's notes: a single `fixed` section with ONE entry. `NSHumanReadableCopyright` said
    /// "ClipMenu modern rewrite." — a tagline in the slot macOS reserves for the bundle's copyright
    /// notice (#80) — and it now names one holder, ClipMenu 2's own (#82). The fix is narrow but
    /// observable, which is what keeps `.fixed` honest here: Finder's Get Info panel reads the key,
    /// so ⌘I on ClipMenu.app shows it. 2.20.3 claimed `.fixed` on a surface just as small
    /// (Homebrew's receipt), and 2.20.2 refused the claim precisely because its fixes were
    /// reachable only from a local Debug build.
    ///
    /// The shape is unchanged from 2.20.7 on purpose. 2.20.7 shipped this same section for the same
    /// key, naming two holders; 2.20.8 restates the entry in the singular and reuses the summary
    /// key verbatim, because the notes describe the END STATE rather than the delta. The pane shows
    /// only the current version's notes, and 2.20.7 existed for about an hour, so nearly every user
    /// arrives from 2.20.6 and needs to be told the tagline is gone — not told about a distinction
    /// between two copyright values they never saw.
    ///
    /// Why one holder: `NSHumanReadableCopyright` is an OPTIONAL Apple key that no licence names,
    /// so it is presentation, and the same argument that fixes About's row at one holder
    /// (CONFORMANCE §R14, pinned by `contentSingleSourcesNameAndCopyright` above) reaches it.
    /// `LICENSE` is where MIT's grant lives and still names both. ice-2 keeps both in its plist and
    /// is right to — a git fork carrying Jordan Baird's source under GPL-3.0 is not this case.
    ///
    /// 2.20.6 pinned two `.fixed` entries: the `Original project` link was absent while `Based on`
    /// credited the project it should have linked, and About's copyright named two holders. 2.20.5
    /// and 2.20.4 pinned `[.changed]` with one entry — a DragonKit bump whose only observable part
    /// was About's "Built with" row, and the SUFeedURL move, which no user can observe at all.
    ///
    /// Pinned per release alongside the WhatsNewConfig copy itself — the section shape IS the claim,
    /// so updating the notes has to update this, which is the point. The release gate checks that
    /// the notes CHANGED; this checks that they changed to what was meant.
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
