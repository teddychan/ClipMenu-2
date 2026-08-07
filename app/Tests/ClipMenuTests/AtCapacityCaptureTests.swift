import Testing
import Foundation
import SwiftData
@testable import ClipMenu

// Regression: a full history must not stop accepting new clips. When the store is
// exactly at maxHistorySize, capture() must persist the new clip and trim the
// OLDEST — not drop the just-captured one. Guards the v2.17.7 bug where trim()
// ran before save() and its fetchOffset descriptor selected the still-pending
// insert as the "overflow", silently discarding every new copy once full.
//
// Uses a disk-backed store because #Index/offset ordering only applies to on-disk
// (SQLite) stores.
//
// Each test injects its OWN UserDefaults suite into capture() rather than writing
// `UserDefaults.standard`. That domain is process-global, and Swift Testing runs
// sibling suites in parallel: a cap leaked from here silently trimmed another
// suite's store — HistoryIndexRepairTests went red in CI (which runs `swift test`
// without --no-parallel) expecting 2 clips and finding 1, while the serial local
// run passed. Injecting removes the shared state instead of ordering around it.
@Suite struct AtCapacityCaptureTests {

    @Test func captureWhenAtCapacityKeepsNewClipAndTrimsOldest() async throws {
        let dir = URL.temporaryDirectory.appending(path: "ClipMenuAtCap-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let config = ModelConfiguration(
            "History", schema: Schema([ClipRecord.self, ClipImage.self]),
            url: dir.appending(path: "History.store"), cloudKitDatabase: .none)

        let cap = 5
        let suite = "AtCap-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defaults.set(cap, forKey: PreferenceKeys.maxHistorySize)

        // Seed exactly `cap` rows (contentHash 0..<cap), oldest first.
        let container = try ModelContainer(for: ClipRecord.self, ClipImage.self, configurations: config)
        let seed = ModelContext(container)
        let base = Date(timeIntervalSince1970: 1_000_000)
        for i in 0 ..< cap {
            let d = base.addingTimeInterval(Double(i))
            seed.insert(ClipRecord(createdDate: d, lastUsedDate: d,
                                   typeIdentifiers: ["String"], stringValue: "seed\(i)", contentHash: i))
        }
        try seed.save()

        // Capture a brand-new clip through the real path.
        let store = ClipStore(modelContainer: container)
        let newHash = 999_999
        await store.capture(PasteboardSnapshot(
            typeNames: ["String"], stringValue: "BRAND NEW", rtfData: nil, pdfData: nil,
            filenames: nil, urlString: nil, imageData: nil, contentHash: newHash),
            defaults: defaults)

        // Reopen the store from disk and assert: new clip present, oldest gone, cap held.
        let ctx = ModelContext(try ModelContainer(for: ClipRecord.self, ClipImage.self, configurations: config))
        let hashes = Set(try ctx.fetch(FetchDescriptor<ClipRecord>()).map(\.contentHash))
        #expect(hashes.contains(newHash), "new clip must be saved even when history is at capacity")
        #expect(!hashes.contains(0), "the oldest clip should be the one trimmed")
        #expect(hashes.count == cap, "history should stay at the cap")
    }

    // Regression (data loss): a maxHistorySize of 0 — reachable from the free-form
    // Settings field — made trim()'s fetchOffset 0, which selects EVERY row, so a
    // single capture wiped the whole history including the clip just inserted (and
    // history is not covered by backup). ClipStore.maxHistorySize now clamps to 1,
    // so capture() keeps the new clip and only trims what is genuinely older.
    @Test func captureWithZeroCapKeepsTheNewClipInsteadOfErasingEverything() async throws {
        let dir = URL.temporaryDirectory.appending(path: "ClipMenuZeroCap-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let config = ModelConfiguration(
            "History", schema: Schema([ClipRecord.self, ClipImage.self]),
            url: dir.appending(path: "History.store"), cloudKitDatabase: .none)

        let suite = "ZeroCap-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defaults.set(0, forKey: PreferenceKeys.maxHistorySize)

        let container = try ModelContainer(for: ClipRecord.self, ClipImage.self, configurations: config)
        let seed = ModelContext(container)
        let base = Date(timeIntervalSince1970: 1_000_000)
        for i in 0 ..< 3 {
            let d = base.addingTimeInterval(Double(i))
            seed.insert(ClipRecord(createdDate: d, lastUsedDate: d,
                                   typeIdentifiers: ["String"], stringValue: "seed\(i)", contentHash: i))
        }
        try seed.save()

        let store = ClipStore(modelContainer: container)
        let newHash = 888_888
        await store.capture(PasteboardSnapshot(
            typeNames: ["String"], stringValue: "SURVIVES", rtfData: nil, pdfData: nil,
            filenames: nil, urlString: nil, imageData: nil, contentHash: newHash),
            defaults: defaults)

        let ctx = ModelContext(try ModelContainer(for: ClipRecord.self, ClipImage.self, configurations: config))
        let hashes = Set(try ctx.fetch(FetchDescriptor<ClipRecord>()).map(\.contentHash))
        #expect(!hashes.isEmpty, "a cap of 0 must not empty the store")
        #expect(hashes.contains(newHash), "the just-captured clip must survive trimming")
        #expect(hashes.count == 1, "the clamped cap of 1 keeps exactly the newest clip")
    }
}
