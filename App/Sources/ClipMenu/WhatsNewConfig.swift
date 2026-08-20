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
            date: "2026-08-20",
            // One user-facing change, inherited from the DragonKit 4.1.0 -> 4.1.1 pin bump (#94):
            // Uninstall now refuses to run when it finds more than one copy of ClipMenu on the
            // Mac. Moving the running copy to the Trash was always safe, but settings, the login
            // item, support files and the Homebrew record are all keyed to the app's identity
            // rather than its location, so two copies share every one of them and there is no way
            // to tell whose is whose — uninstalling a spare copy could wipe the settings belonging
            // to the copy actually in use. `.fixed`, not `.changed`: something was broken (a spare
            // copy could silently destroy the real copy's data), and now it cannot.
            //
            // DragonKit 4.1.1 also carries a second fix — a raw developer error that
            // Settings > Updates could surface — but that only ever reached local Debug builds,
            // never a shipped copy, so no entry claims it here. Writing one anyway would be
            // exactly the lie the release gate exists to catch (2.20.2 and 2.21.0 both refused the
            // same temptation from either direction); it is recorded in CHANGELOG.md instead, which
            // is where developer-facing fixes belong.
            //
            // The `.changed` entry names the DragonKit bump itself, the same shape 2.20.10's did
            // for its own pin move: the one thing a user can observe beyond the fix above is
            // About's "Built with · DragonKit v4.1.1" row, and the entry claims exactly that.
            //
            // Three new keys enter the `.lproj` files this release — summary, fixed, changed — none
            // of the earlier maintenance-release keys apply to a release with real user-facing
            // content, so this is the first time since 2.20.10 the notes need fresh translations
            // rather than reusing verbatim ones.
            summary: L("app.whatsNew.summary"),
            sections: [
                // One section. 2.21.2 renames nothing but the app's own name, and 2.21.1's
                // `.fixed` uninstall entry is dropped rather than carried forward — it shipped
                // there, and repeating it would tell a user the same fix landed twice.
                ChangeSection(kind: .changed, entries: [
                    L("app.whatsNew.changed1"),
                ]),
            ]
        )
    }
}
