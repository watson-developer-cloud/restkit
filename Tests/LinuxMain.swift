import XCTest

@testable import RestKitTests

XCTMain([
    testCase(AuthenticationTests.allTests),
    testCase(CodableExtensionsTests.allTests),
    testCase(JSONTests.allTests),
    testCase(RestErrorTests.allTests),
    testCase(ResponseTests.allTests),
    testCase(MultiPartFormDataTests.allTests),
])
