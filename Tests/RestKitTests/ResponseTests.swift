/**
 * Copyright IBM Corporation 2018, 2019
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
import RestKit

class ResponseTests: XCTestCase {

    // Mock URLSession
    var configuration: URLSessionConfiguration!
    var mockSession: URLSession!

    override func setUp() {
        configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
    }

    static var allTests = [
        ("testDataCorruptedError", testDataCorruptedError),
        ("testKeyNotFoundError", testKeyNotFoundError),
        ("testTypeMismatchError", testTypeMismatchError),
        ("testValueNotFoundError", testValueNotFoundError),
    ]

    // MARK: - Tests

    func testDataCorruptedError() {
        // Configure mock
        MockURLProtocol.requestHandler = { request in
            // Setup mock result
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = "{ \"id\": \"12345\", \"status\": { \"created\": \"\" } }".data(using: .utf8)
            return (response, data)
        }

        let request = RestRequest(
            session: mockSession,
            authMethod: BasicAuthentication(username: "username", password: "password"),
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: "http://restkit.com/response_tests/test_data_corrputed_error",
            headerParameters: [:]
        )

        let expectation = self.expectation(description: #function)
        request.responseObject { (response: RestResponse<Document>?, error: RestError?) in
            guard let error = error else {
                XCTFail("Expected error not received")
                return
            }
            let expected = "Failed to deserialize response JSON: dataCorrupted at status.created: Date string does not match format expected by formatter."
            XCTAssertEqual(expected, error.localizedDescription)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testKeyNotFoundError() {
        // Configure mock
        MockURLProtocol.requestHandler = { request in
            // Setup mock result
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = "{ \"name\": \"A document with no id\"}".data(using: .utf8)
            return (response, data)
        }

        let request = RestRequest(
            session: mockSession,
            authMethod: BasicAuthentication(username: "username", password: "password"),
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: "http://restkit.com/response_tests/test_key_not_found_error",
            headerParameters: [:]
        )

        let expectation = self.expectation(description: #function)
        request.responseObject { (response: RestResponse<Document>?, error: RestError?) in
            guard let error = error else {
                XCTFail("Expected error not received")
                return
            }
            let expected = "Failed to deserialize response JSON: key not found for id"
            XCTAssertEqual(expected, error.localizedDescription)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testTypeMismatchError() {
        // Configure mock
        MockURLProtocol.requestHandler = { request in
            // Setup mock result
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = "{ \"id\": \"12345\", \"status\": { \"updated\": 3.14159626 } }".data(using: .utf8)
            return (response, data)
        }

        let request = RestRequest(
            session: mockSession,
            authMethod: BasicAuthentication(username: "username", password: "password"),
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: "http://restkit.com/response_tests/test_type_mismatch_error",
            headerParameters: [:]
        )

        let expectation = self.expectation(description: #function)
        request.responseObject { (response: RestResponse<Document>?, error: RestError?) in
            guard let error = error else {
                XCTFail("Expected error not received")
                return
            }
            let expected = "Failed to deserialize response JSON: type mismatch for status.updated: Expected to decode String but found a number instead."
            XCTAssertEqual(expected, error.localizedDescription)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testValueNotFoundError() {
        // Configure mock
        MockURLProtocol.requestHandler = { request in
            // Setup mock result
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = "{ \"id\": null, \"name\": \"document with null id\" }".data(using: .utf8)
            return (response, data)
        }

        let request = RestRequest(
            session: mockSession,
            authMethod: BasicAuthentication(username: "username", password: "password"),
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: "http://restkit.com/response_tests/test_value_not_found_error",
            headerParameters: [:]
        )

        let expectation = self.expectation(description: #function)
        request.responseObject { (response: RestResponse<Document>?, error: RestError?) in
            guard let error = error else {
                XCTFail("Expected error not received")
                return
            }
            let expected = "Failed to deserialize response JSON: value not found for id: Expected String value but found null instead."
            XCTAssertEqual(expected, error.localizedDescription)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testErrorHeaders() {
        let headers = ["foo": "bar" ]
        // Configure mock
        MockURLProtocol.requestHandler = { request in
            // Setup mock result
            let response = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: headers)!
            let data = "{ \"code\": \"42\", \"message\": \"Error with code 42\" }".data(using: .utf8)
            return (response, data)
        }

        let request = RestRequest(
            session: mockSession,
            authMethod: BasicAuthentication(username: "username", password: "password"),
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: "http://restkit.com/response_tests/test_value_not_found_error",
            headerParameters: [:]
        )

        let expectation = self.expectation(description: #function)
        request.responseObject { (response: RestResponse<Document>?, error: RestError?) in
            XCTAssertNotNil(error)
            guard let response = response else {
                XCTFail("Expected response not received")
                return
            }
            XCTAssertEqual(headers, response.headers)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testBadURL() {
        let request = RestRequest(
            session: mockSession,
            authMethod: BasicAuthentication(username: "username", password: "password"),
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: "not valid",
            headerParameters: [:]
        )

        let expectation = self.expectation(description: #function)
        request.responseObject { (response: RestResponse<Document>?, error: RestError?) in
            guard case .some(.badURL) = error else {
                XCTFail("Expected error not received")
                return
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    // MARK: - Helpers

    class Document : Codable {
        let id: String
        let name: String?
        let status: DocumentStatus?
    }

    class DocumentStatus : Codable {
        let created: Date?
        let updated: Date?
    }

    func errorResponseDecoder(data: Data, response: HTTPURLResponse) -> RestError {
        let statusCode = response.statusCode
        return RestError.http(statusCode: statusCode, message: "error message", metadata: nil)
    }
}
