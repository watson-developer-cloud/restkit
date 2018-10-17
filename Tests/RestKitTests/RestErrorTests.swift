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
    ]

    func testHTTPErrorStatusCode() {
        let testStatusCode = 400
        let httpError = RestError.http(statusCode: testStatusCode, message: "Success")

        XCTAssertEqual(httpError.statusCode, testStatusCode)
    }

    func testHTTPErrorMessage() {
        let testMessage = "Something went wrong"
        let httpError = RestError.http(statusCode: 500, message: testMessage)

        XCTAssertEqual(httpError.errorDescription, testMessage)
    }

    func testHTTPErrorMetadata() {
        let testStatusCode = 500
        let testMessage = "Something went wrong"
        let httpError = RestError.http(statusCode: testStatusCode, message: testMessage)

        XCTAssertEqual(httpError.metadata!["status_code"]!, JSON.int(testStatusCode))
        XCTAssertEqual(httpError.metadata!["message"]!, JSON.string(testMessage))
    }
}
