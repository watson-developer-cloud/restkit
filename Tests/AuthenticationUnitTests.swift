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

// swiftlint:disable function_body_length force_try force_unwrapping file_length

import XCTest
@testable import RestKit

class AuthenticationUnitTests: XCTestCase {

    // Mock URLSession
    var configuration: URLSessionConfiguration!
    var mockSession: URLSession!

    override func setUp() {
        configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
    }

    static var allTests = [
        ("testNoAuthAuthenticator", testNoAuthAuthenticator),
        ("testBasicAuthenticator", testBasicAuthenticator),
        ("testBearerAuthenticator", testBearerAuthenticator),
        ("testIAMToken", testIAMToken),
        ("testIAMAuthenticator", testIAMAuthenticator),
    ]

    internal static func errorResponseDecoder(data: Data, response: HTTPURLResponse) -> RestError {
        let genericMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
        return RestError.http(statusCode: response.statusCode, message: genericMessage, metadata: nil)
    }

    var request = RestRequest(
        session: URLSession(configuration: URLSessionConfiguration.default),
        authenticator: NoAuthAuthenticator(),
        errorResponseDecoder: errorResponseDecoder,
        method: "GET",
        url: "http://www.example.com",
        headerParameters: ["x-custom-header": "value"],
        queryItems: [URLQueryItem(name: "name", value: "value")],
        messageBody: "hello-world".data(using: .utf8)
    )

    func testNoAuthAuthenticator() {
        request.authenticator = NoAuthAuthenticator()
        request.authenticator.authenticate(request: request) { request, error in
            guard let request = request, error == nil else { XCTFail(error!.localizedDescription); return }
            XCTAssertEqual(self.request.method, request.method)
            XCTAssertEqual(self.request.url, request.url)
            XCTAssertEqual(self.request.headerParameters, request.headerParameters)
            XCTAssertEqual(self.request.queryItems, request.queryItems)
            XCTAssertEqual(self.request.messageBody, request.messageBody)
        }
    }

    func testBasicAuthenticator() {
        let authentication = "Basic dXNlcm5hbWU6cGFzc3dvcmQ="
        request.authenticator = BasicAuthenticator(username: "username", password: "password")
        request.authenticator.authenticate(request: request) { request, error in
            guard let request = request, error == nil else { XCTFail(error!.localizedDescription); return }
            XCTAssertEqual(self.request.method, request.method)
            XCTAssertEqual(self.request.url, request.url)
            XCTAssertEqual(request.headerParameters["x-custom-header"], "value")
            XCTAssertEqual(request.headerParameters["Authorization"], authentication)
            XCTAssertEqual(self.request.queryItems, request.queryItems)
            XCTAssertEqual(self.request.messageBody, request.messageBody)
        }
    }

    func testBearerAuthenticator() {
        request.authenticator = BearerAuthenticator(bearerToken: "bearer-token")
        request.authenticator.authenticate(request: request) { request, error in
            guard let request = request, error == nil else { XCTFail(error!.localizedDescription); return }
            XCTAssertEqual(self.request.method, request.method)
            XCTAssertEqual(self.request.url, request.url)
            XCTAssertEqual(request.headerParameters["x-custom-header"], "value")
            XCTAssertEqual(request.headerParameters["Authorization"], "Bearer bearer-token")
            XCTAssertEqual(self.request.queryItems, request.queryItems)
            XCTAssertEqual(self.request.messageBody, request.messageBody)
        }
    }

    func testIAMToken() {
        // test JSON decoding
        let json = """
        {
            "access_token": "foo",
            "refresh_token":"bar",
            "token_type": "Bearer",
            "expires_in": 3600,
            "expiration": 1524754769
        }
        """
        let token1 = try! JSONDecoder().decode(IAMToken.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(token1.accessToken, "foo")
        XCTAssertEqual(token1.refreshToken, "bar")
        XCTAssertEqual(token1.tokenType, "Bearer")
        XCTAssertEqual(token1.expiresIn, 3600)
        XCTAssertEqual(token1.expiration, 1524754769)
    }

    func testIAMAuthenticator() {
        let authenticator = IAMAuthenticator(apiKey: TestCredentials.IAMAPIKey, url: TestCredentials.IAMURL)
        let iamTokenSource = authenticator.tokenSource as! IAMTokenSource
        iamTokenSource.session = mockSession
        request.authenticator = authenticator

        // Configure mock
        MockURLProtocol.requestHandler = { request in
            // Setup mock result
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let expiration = Int(Date().addingTimeInterval(2).timeIntervalSince1970)
            let data = """
                { \"access_token\": \"token\",
                \"refresh_token\": \"refresh\",
                \"token_type\": \"Bearer\",
                \"expires_in\": 2,
                \"expiration\": \(expiration)}
                """.data(using: .utf8)
            return (response, data)
        }

        // request initial iam token
        let expectation1 = self.expectation(description: "request initial iam token")
        request.authenticator.authenticate(request: request) { request, error in
            guard let request = request, error == nil else { XCTFail(error!.localizedDescription); return }
            XCTAssertEqual(self.request.method, request.method)
            XCTAssertEqual(self.request.url, request.url)
            XCTAssertEqual(request.headerParameters["x-custom-header"], "value")
            XCTAssertEqual(request.headerParameters["Authorization"], "Bearer token")
            XCTAssertEqual(self.request.queryItems, request.queryItems)
            XCTAssertEqual(self.request.messageBody, request.messageBody)
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1)

        sleep(3)

        // Set headers for token request
        authenticator.requestHeaders = ["x-special-header": "special value"]

        // Set clientID and clientSecret for token request
        authenticator.setClientCredentials(clientID: "clientID", clientSecret: "clientSecret")

        // Configure mock
        MockURLProtocol.requestHandler = { request in

            // Verify fields in token request
            XCTAssertNotNil(request.allHTTPHeaderFields)
            XCTAssertEqual(request.allHTTPHeaderFields!["x-special-header"], "special value")
            XCTAssertEqual(request.allHTTPHeaderFields!["Authorization"],"Basic Y2xpZW50SUQ6Y2xpZW50U2VjcmV0")

            // Setup mock result
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let expiration = Int(Date().addingTimeInterval(3600).timeIntervalSince1970)
            let data = """
                { \"access_token\": \"new_token\",
                \"refresh_token\": \"refresh\",
                \"token_type\": \"Bearer\",
                \"expires_in\": 3600,
                \"expiration\": \(expiration)}
                """.data(using: .utf8)
            return (response, data)
        }

        // request new iam token
        let expectation2 = self.expectation(description: "request new iam token")
        request.authenticator.authenticate(request: request) { request, error in
            guard let request = request, error == nil else { XCTFail(error!.localizedDescription); return }
            XCTAssertEqual(self.request.method, request.method)
            XCTAssertEqual(self.request.url, request.url)
            XCTAssertEqual(request.headerParameters["x-custom-header"], "value")
            XCTAssertEqual(request.headerParameters["Authorization"], "Bearer new_token")
            XCTAssertEqual(self.request.queryItems, request.queryItems)
            XCTAssertEqual(self.request.messageBody, request.messageBody)
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1)
    }

    func testCP4DAuthenticator() {
        let authenticator = CloudPakForDataAuthenticator(username: "username", password: "password", url: "https://foo.bar.com/identity")
        let cp4dTokenSource = authenticator.tokenSource as! CloudPakForDataTokenSource
        cp4dTokenSource.session = mockSession
        request.authenticator = authenticator

        let token = ["header", "{\"exp\": 2}".data(using: .utf8)!.base64EncodedString(), "signature"].joined(separator: ".")

        // Configure mock
        MockURLProtocol.requestHandler = { request in
            // Setup mock result
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = "{ \"accessToken\": \"\(token)\" }".data(using: .utf8)
            return (response, data)
        }

        // request initial cp4d token
        let expectation1 = self.expectation(description: "request initial cp4d token")
        request.authenticator.authenticate(request: request) { request, error in
            guard let request = request, error == nil else { XCTFail(error!.localizedDescription); return }
            XCTAssertEqual(self.request.method, request.method)
            XCTAssertEqual(self.request.url, request.url)
            XCTAssertEqual(request.headerParameters["x-custom-header"], "value")
            XCTAssertEqual(request.headerParameters["Authorization"], "Bearer \(token)")
            XCTAssertEqual(self.request.queryItems, request.queryItems)
            XCTAssertEqual(self.request.messageBody, request.messageBody)
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1)

        sleep(3)

        // Set headers for token request
        authenticator.requestHeaders = ["x-special-header": "special value"]

        let newToken = ["header", "{\"exp\": 3600}".data(using: .utf8)!.base64EncodedString(), "signature"].joined(separator: ".")

        // Configure mock
        MockURLProtocol.requestHandler = { request in

            // Verify fields in token request
            XCTAssertNotNil(request.allHTTPHeaderFields)
            XCTAssertEqual(request.allHTTPHeaderFields!["x-special-header"], "special value")
 
            // Setup mock result
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
             let data = "{ \"accessToken\": \"\(newToken)\" }".data(using: .utf8)
            return (response, data)
        }

        // request new cp4d token
        let expectation2 = self.expectation(description: "request new cp4d token")
        request.authenticator.authenticate(request: request) { request, error in
            guard let request = request, error == nil else { XCTFail(error!.localizedDescription); return }
            XCTAssertEqual(self.request.method, request.method)
            XCTAssertEqual(self.request.url, request.url)
            XCTAssertEqual(request.headerParameters["x-custom-header"], "value")
            XCTAssertEqual(request.headerParameters["Authorization"], "Bearer \(newToken)")
            XCTAssertEqual(self.request.queryItems, request.queryItems)
            XCTAssertEqual(self.request.messageBody, request.messageBody)
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1)
    }
}
