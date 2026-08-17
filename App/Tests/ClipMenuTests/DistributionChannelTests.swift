import Testing
@testable import ClipMenu

// Pins the App-Store-vs-direct decision. Sandboxed macOS apps always have
// APP_SANDBOX_CONTAINER_ID in their environment; direct/Developer ID builds
// do not. The decision is factored into a pure function so both branches are
// testable without an actual sandbox.
@Suite struct DistributionChannelTests {

    @Test func sandboxedEnvironmentIsAppStore() {
        let env = ["APP_SANDBOX_CONTAINER_ID": "ABCDE12345.com.dragonapp.clipmenu-2"]
        #expect(DistributionChannel.detect(environment: env) == .appStore)
    }

    @Test func nonSandboxedEnvironmentIsDirect() {
        #expect(DistributionChannel.detect(environment: [:]) == .direct)
    }
}

// The other decision this channel drives, and the one where getting it wrong is destructive.
//
// `brew uninstall --cask clipmenu-2 --force` is not bundle-scoped: it deletes whatever brew's
// receipt points at — the release app in /Applications — and `Casks/clipmenu-2.rb` carries
// `uninstall quit: "com.dragonapp.clipmenu-2"`, so it terminates that app first. Every build that
// Homebrew did not install therefore has to issue no token at all, and there are three of them:
// the local Debug build, the sandboxed App Store build, and a build that cannot state its own id.
//
// The last one is not hypothetical: ice-2 and the sample app both wrote
// `Bundle.main.bundleIdentifier ?? releaseBundleID` and so answered the release id for exactly the
// build least entitled to authorise a delete.
@MainActor
@Suite struct HomebrewCaskTokenTests {

    @Test func theInstalledReleaseGetsTheToken() {
        #expect(SettingsWindowController.homebrewCaskToken(
            channel: .direct, actual: SettingsWindowController.releaseBundleID) == "clipmenu-2")
    }

    @Test func theDebugBuildGetsNothing() {
        #expect(SettingsWindowController.homebrewCaskToken(
            channel: .direct, actual: "\(SettingsWindowController.releaseBundleID).debug") == nil)
    }

    /// Sandboxed, and carrying the *same* bundle id as the direct build — so the bundle-id
    /// comparison alone cannot exclude it and the channel has to.
    @Test func theAppStoreBuildGetsNothingDespiteTheReleaseBundleID() {
        #expect(SettingsWindowController.homebrewCaskToken(
            channel: .appStore, actual: SettingsWindowController.releaseBundleID) == nil)
    }

    @Test func aBuildWithNoBundleIDGetsNothing() {
        #expect(SettingsWindowController.homebrewCaskToken(channel: .direct, actual: nil) == nil)
        // Two empty strings must not match each other either.
        #expect(SettingsWindowController.homebrewCaskToken(channel: .direct, actual: "") == nil)
    }

    @Test func anotherAppsBundleIDGetsNothing() {
        #expect(SettingsWindowController.homebrewCaskToken(
            channel: .direct, actual: "com.dragonapp.ice") == nil)
    }
}
