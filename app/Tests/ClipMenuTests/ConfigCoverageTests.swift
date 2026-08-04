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
        #expect(content.copyright == AppInfo.copyright)
        #expect(content.versionString == DragonAbout.versionString())
        #expect(!content.versionString.isEmpty)
    }

    @Test func contentHasWebsiteAndSupportLinks() {
        let links = AboutConfig.content.links
        #expect(links.count == 2)

        let website = links[0]
        #expect(website.detail == "dragonapp.com/clipmenu")
        #expect(website.systemImage == "globe")
        #expect(website.url.absoluteString == "https://www.dragonapp.com/clipmenu")

        let support = links[1]
        #expect(support.detail == "teddychan/clipmenu-2")
        #expect(support.systemImage == "lifepreserver")
        #expect(support.url.absoluteString == "https://github.com/teddychan/clipmenu-2/issues")
    }

    @Test func contentCreditsAuthorsAndLicense() {
        let credits = AboutConfig.content.credits
        #expect(credits.count == 3)
        #expect(credits.map(\.value) == ["Teddy Chan", "Naotaka Morimoto", "MIT"])
    }
}

@MainActor
@Suite struct WhatsNewConfigCoverageTests {

    @Test func versionIsPrefixedFromAppInfo() {
        #expect(WhatsNewConfig.content.version == "v\(AppInfo.version)")
    }

    @Test func contentHasDateAndSummary() {
        let content = WhatsNewConfig.content
        #expect(content.date == "2026-08-04")
        #expect(!content.summary.isEmpty)
    }

    /// 2.19.0's notes: Uninstall left the menu (removed) and now lives in Settings
    /// (changed). Pinned per release alongside the WhatsNewConfig copy itself.
    @Test func contentHasARemovedThenChangedSection() {
        let sections = WhatsNewConfig.content.sections
        #expect(sections.count == 2)
        #expect(sections.map(\.kind) == [.removed, .changed])
        for section in sections {
            #expect(section.entries.count == 1)
            #expect(!(section.entries.first ?? "").isEmpty)
        }
    }
}
