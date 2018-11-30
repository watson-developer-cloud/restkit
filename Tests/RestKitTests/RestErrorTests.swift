/**
 * Copyright IBM Corporation 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
@testable import RestKit

class RestErrorTests: XCTestCase {

    static var allTests = [
        ("testHTTPErrorStatusCode", testHTTPErrorStatusCode),
        ("testHTTPErrorMessage", testHTTPErrorMessage),
        ("testHTTPErrorMetadata", testHTTPErrorMetadata),
    ]

    func testHTTPErrorStatusCode() {
        let testStatusCode = 400
        let httpError = RestError.http(statusCode: testStatusCode, message: "Success", metadata: nil)

        guard case RestError.http(let statusCode, _, _) = httpError else {
            XCTFail("Expected RestError.http")
        }
        XCTAssertEqual(statusCode, testStatusCode)
    }

    func testHTTPErrorMessage() {
        let testMessage = "Something went wrong"
        let httpError = RestError.http(statusCode: 500, message: testMessage, metadata: nil)

        guard case RestError.http(_, let message, _) = httpError else {
            XCTFail("Expected RestError.http")
        }
        XCTAssertEqual(message, testMessage)
        XCTAssertEqual(httpError.errorDescription, testMessage)
    }

    func testHTTPErrorMetadata() {
        let testStatusCode = 500
        let testMetadata: [String: Any] = [
            "key0": 42,
            "key1": true,
            "key2": "value"
        ]
        let httpError = RestError.http(statusCode: testStatusCode, message: nil, metadata: testMetadata)

        guard case RestError.http(_, _, let metadata) = httpError else {
            XCTFail("Expected RestError.http")
        }
        XCTAssertEqual(metadata!["key0"] as? Int, 42)
        XCTAssertEqual(metadata!["key1"] as? Bool, true)
        XCTAssertEqual(metadata!["key2"] as? String, "value")
    }
}
