import XCTest

@testable import RestKitTests

XCTMain([
    testCase(AuthenticationTests.allTests),
    testCase(CodableExtensionsTests.allTests),
    testCase(JSONTests.allTests),
])
