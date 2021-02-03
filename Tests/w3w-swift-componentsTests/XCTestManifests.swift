import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(w3w_swift_componentsTests.allTests),
    ]
}
#endif
