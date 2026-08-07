import Testing
import Foundation
import SwiftData
@testable import ClipMenu

// The single bounded-history fetch policy that the menu, the history search, and
// the Export… action all share (ClipStore.boundedHistoryDescriptor). Proving the
// cap here proves it for every caller: none of them can ever materialize more
// than `maxHistorySize` clips (CLAUDE.md §2/§4).
@Suite @MainActor
struct HistoryBoundsTests {
    private func inMemoryContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: Folder.self, Snippet.self, ClipRecord.self, ClipImage.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return ModelContext(container)
    }

    @Test func maxHistorySizeDefaultsTo20() {
        let suite = "HistoryBoundsDefault-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        #expect(ClipStore.maxHistorySize(defaults) == 20)
    }

    // The Settings field is free-form, so 0 or a negative cap can reach the store.
    // Neither means "keep nothing" to the descriptors below (fetchLimit = 0 is "no
    // limit", fetchOffset = 0 selects every row), so the single source of truth
    // clamps to 1. Sane values pass through untouched.
    @Test func maxHistorySizeClampsNonPositiveStoredValuesToOne() {
        let suite = "HistoryBoundsClamp-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)

        defaults.set(0, forKey: PreferenceKeys.maxHistorySize)
        #expect(ClipStore.maxHistorySize(defaults) == 1)
        defaults.set(-5, forKey: PreferenceKeys.maxHistorySize)
        #expect(ClipStore.maxHistorySize(defaults) == 1)
        defaults.set(50, forKey: PreferenceKeys.maxHistorySize)
        #expect(ClipStore.maxHistorySize(defaults) == 50)
    }

    @Test func boundedDescriptorReturnsNewestMaxHistorySize() throws {
        let context = try inMemoryContext()
        let base = Date(timeIntervalSince1970: 1_000_000)
        for i in 0 ..< 5 {
            let date = base.addingTimeInterval(Double(i))
            context.insert(ClipRecord(createdDate: date, lastUsedDate: date,
                                      typeIdentifiers: ["String"], stringValue: "clip\(i)", contentHash: i))
        }
        try context.save()

        let suite = "HistoryBounds-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defaults.set(3, forKey: PreferenceKeys.maxHistorySize)

        let clips = try context.fetch(ClipStore.boundedHistoryDescriptor(defaults))
        #expect(clips.count == 3)
        // Newest first, oldest two excluded.
        #expect(clips.map(\.contentHash) == [4, 3, 2])
    }

    // trim() deletes exactly what boundedHistoryDescriptor does NOT keep: the clips
    // past the cap, oldest first. Proving the overflow descriptor here proves the
    // on-disk history matches the in-view cap.
    @Test func trimOverflowDescriptorSelectsOldestBeyondCap() throws {
        let context = try inMemoryContext()
        let base = Date(timeIntervalSince1970: 1_000_000)
        for i in 0 ..< 5 {
            let date = base.addingTimeInterval(Double(i))
            context.insert(ClipRecord(createdDate: date, lastUsedDate: date,
                                      typeIdentifiers: ["String"], stringValue: "clip\(i)", contentHash: i))
        }
        try context.save()

        let suite = "TrimOverflow-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defaults.set(3, forKey: PreferenceKeys.maxHistorySize)

        let overflow = try context.fetch(ClipStore.trimOverflowDescriptor(defaults))
        // The two oldest (hashes 0 and 1) are the overflow to drop.
        #expect(overflow.count == 2)
        #expect(Set(overflow.map(\.contentHash)) == [0, 1])
    }

    // Regression (data loss): with the cap stored as 0 the overflow fetch ran with
    // fetchOffset = 0, which selects EVERY row — so trim() deleted the whole history
    // on the next capture. Clamped to 1, the newest clip is never in the overflow,
    // and a store already down to one clip yields nothing to delete at all.
    @Test func trimOverflowDescriptorAtZeroCapNeverSelectsTheNewestClip() throws {
        let context = try inMemoryContext()
        let base = Date(timeIntervalSince1970: 1_000_000)
        for i in 0 ..< 5 {
            let date = base.addingTimeInterval(Double(i))
            context.insert(ClipRecord(createdDate: date, lastUsedDate: date,
                                      typeIdentifiers: ["String"], stringValue: "clip\(i)", contentHash: i))
        }
        try context.save()

        let suite = "TrimOverflowZero-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defaults.set(0, forKey: PreferenceKeys.maxHistorySize)

        let overflow = try context.fetch(ClipStore.trimOverflowDescriptor(defaults))
        #expect(overflow.count == 4)
        #expect(!overflow.map(\.contentHash).contains(4), "the newest clip must never be trimmed")

        // Down to a single clip, the overflow is empty: nothing left to delete.
        for record in overflow { context.delete(record) }
        try context.save()
        #expect(try context.fetch(ClipStore.trimOverflowDescriptor(defaults)).isEmpty)
    }

    // The other half of the cap-0 bug: fetchLimit = 0 means "no limit" to SwiftData,
    // so the menu/search/export path would have materialized the ENTIRE store.
    @Test func boundedDescriptorAtZeroCapReturnsOnlyTheClampedCount() throws {
        let context = try inMemoryContext()
        let base = Date(timeIntervalSince1970: 1_000_000)
        for i in 0 ..< 5 {
            let date = base.addingTimeInterval(Double(i))
            context.insert(ClipRecord(createdDate: date, lastUsedDate: date,
                                      typeIdentifiers: ["String"], stringValue: "clip\(i)", contentHash: i))
        }
        try context.save()

        let suite = "HistoryBoundsZero-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defaults.set(0, forKey: PreferenceKeys.maxHistorySize)

        let clips = try context.fetch(ClipStore.boundedHistoryDescriptor(defaults))
        #expect(clips.count == 1)
        #expect(clips.map(\.contentHash) == [4])   // the newest, not all five
    }

    // Lowering the cap must delete the overflow THERE AND THEN. `trim()` only runs
    // inside capture(), so before `enforceCapNow` the older clips stayed on disk
    // until the user next copied something — while boundedHistoryDescriptor already
    // hid them from the menu. Lowering the cap to prune history therefore looked
    // like it had worked, and raising it again brought every clip back.
    @Test func enforceCapNowDeletesTheOverflowImmediately() throws {
        let context = try inMemoryContext()
        let base = Date(timeIntervalSince1970: 1_000_000)
        for i in 0 ..< 5 {
            let date = base.addingTimeInterval(Double(i))
            context.insert(ClipRecord(createdDate: date, lastUsedDate: date,
                                      typeIdentifiers: ["String"], stringValue: "clip\(i)", contentHash: i))
        }
        try context.save()

        let suite = "EnforceCap-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defaults.set(2, forKey: PreferenceKeys.maxHistorySize)

        #expect(ClipStore.overflowCount(beyondCap: 2, in: context) == 3)
        #expect(ClipStore.enforceCapNow(in: context, defaults: defaults) == 3)

        // Only the two newest survive, and re-raising the cap can't resurrect the rest.
        let remaining = try context.fetch(FetchDescriptor<ClipRecord>())
        #expect(remaining.count == 2)
        #expect(Set(remaining.map(\.contentHash)) == [4, 3])
        defaults.set(100, forKey: PreferenceKeys.maxHistorySize)
        #expect(try context.fetchCount(FetchDescriptor<ClipRecord>()) == 2)
    }

    /// Nothing to delete must stay a no-op, so raising the cap (or re-confirming at
    /// the same one) never touches the store.
    @Test func enforceCapNowIsANoOpWhenTheStoreIsUnderTheCap() throws {
        let context = try inMemoryContext()
        context.insert(ClipRecord(typeIdentifiers: ["String"], stringValue: "only", contentHash: 1))
        try context.save()

        let suite = "EnforceCapNoOp-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defaults.set(20, forKey: PreferenceKeys.maxHistorySize)

        #expect(ClipStore.overflowCount(beyondCap: 20, in: context) == 0)
        #expect(ClipStore.enforceCapNow(in: context, defaults: defaults) == 0)
        #expect(try context.fetchCount(FetchDescriptor<ClipRecord>()) == 1)
    }

    // The accepted ranges for the free-form numeric fields. Pinned because each
    // bound encodes a real constraint the consuming code depends on, and because
    // the Settings pane and the onboarding wizard had already drifted apart
    // (1...999 there vs unbounded here) — they now share these constants.
    @Test func numericPreferenceRangesAreBounded() {
        // Never 0: to the fetch descriptors it feeds, 0 means "no limit" / "select
        // everything", which is what destroyed the history.
        #expect(PreferenceRanges.maxHistorySize == 1...2000)
        // The one field whose floor is 0 — that is its shipped default, meaning
        // "group every clip into folders" rather than an unset value.
        #expect(PreferenceRanges.numberOfItemsPlaceInline == 0...2000)
        #expect(PreferenceRanges.numberOfItemsPlaceInsideFolder == 1...2000)
        #expect(PreferenceRanges.maxMenuItemTitleLength == 1...2000)
        // A tool tip exists to preview MORE than the menu title shows, so a tiny
        // cap is pointless; "off" is the separate toggle.
        #expect(PreferenceRanges.maxLengthOfToolTip == 100...2000)
        // Capped at the stored thumbnail's own resolution — past it every menu open
        // would decode from the multi-MB original.
        #expect(PreferenceRanges.thumbnailMaxSize == 16...Thumbnailer.storedMaxPixelSize)

        // Whatever the policy, no field may permit a value the safety clamps below
        // still have to rescue.
        for range in [PreferenceRanges.maxHistorySize,
                      PreferenceRanges.numberOfItemsPlaceInsideFolder,
                      PreferenceRanges.maxMenuItemTitleLength,
                      PreferenceRanges.maxLengthOfToolTip,
                      PreferenceRanges.thumbnailMaxSize] {
            #expect(range.lowerBound >= 1)
            #expect(range.upperBound <= 2000)
        }
        #expect(PreferenceRanges.numberOfItemsPlaceInline.lowerBound >= 0)
    }

    // Capturing the same content twice must not create a second row: the dedup
    // lookup bumps the existing clip instead (ClipsController.m:619-636).
    @Test func captureDeduplicatesByContentHash() async throws {
        let container = try ModelContainer(
            for: Folder.self, Snippet.self, ClipRecord.self, ClipImage.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let store = ClipStore(modelContainer: container)
        let snapshot = PasteboardSnapshot(
            typeNames: ["String"], stringValue: "hello", rtfData: nil, pdfData: nil,
            filenames: nil, urlString: nil, imageData: nil, contentHash: 42)

        await store.capture(snapshot)
        await store.capture(snapshot)   // identical → dedup, no second row

        let context = ModelContext(container)
        let count = try context.fetchCount(FetchDescriptor<ClipRecord>())
        #expect(count == 1)
    }
}
