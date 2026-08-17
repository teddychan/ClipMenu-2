import Testing

// Serialization umbrella for every suite that mutates the process-global
// NSPasteboard.general.
//
// `.serialized` on a single suite only orders the tests *within* that suite —
// it does NOT stop two different suites from running at the same time, and
// swift-testing runs distinct suites in parallel by default. Five suites here
// write NSPasteboard.general (ActionEngineApplyCoverageTests,
// BuiltInActionsEffectCoverageTests, PasteboardMonitorCoverageTests,
// PasteboardReaderCoverageTests, PasterCoverageTests), so each one's
// clearContents()/declareTypes() could land inside another's write→read window:
// the reader saw a cleared board (nil) or another suite's string. The two
// non-@MainActor suites made it worse by running on background executors
// concurrently with the @MainActor ones.
//
// Nesting them all in this one `.serialized` suite makes the trait apply to the
// whole subtree, so the five run one at a time relative to EACH OTHER. New
// suites that touch NSPasteboard.general must be nested here too.
@Suite(.serialized) struct PasteboardSerialized {}
