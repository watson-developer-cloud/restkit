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
import RestKit
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class AuthenticationTests: XCTestCase {

    static var allTests = [
        ("testConstructors", testConstructors),
        ("testIAMAuthenticator", testIAMAuthenticator),
        ("testCP4DAuthenticator", testCP4DAuthenticator),
        ("testIAMAuthentication", testIAMAuthentication),
        ("testCP4DTokenSource", testCP4DTokenSource),
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

    // MARK: - Tests

    func testConstructors() {
        // Make sure all Authenticators have public constructors
        let noAuth = NoAuthAuthenticator()
        XCTAssertNotNil(noAuth)
        let basic = BasicAuthenticator(username: "username", password: "password")
        XCTAssertNotNil(basic)
        let bearer = BearerTokenAuthenticator(bearerToken: "bearer")
        XCTAssertNotNil(bearer)
        let iam = IAMAuthenticator(apiKey: "apikey")
        XCTAssertNotNil(iam)
        let cp4d = CloudPakForDataAuthenticator(username: "admin", password: "password", url: "url")
        XCTAssertNotNil(cp4d)
    }

    func testIAMAuthenticator() {
        let iam = IAMAuthenticator(apiKey: "apikey")
        XCTAssertNotNil(iam)

        // Verify that request headers can be set and retrieved
        iam.headers = ["X-custom-header": "my special value"]
        XCTAssertEqual(iam.headers!["X-custom-header"], "my special value")

        #if !os(Linux)
        // Verify that SSL verification can be disabled
        iam.disableSSLVerification()
        #endif

        // Verify that clientID and clientSecret can be set
        iam.setClientCredentials(clientID: "clientID", clientSecret: "clientSecret")
    }

    func testCP4DAuthenticator() {
        let cp4d = CloudPakForDataAuthenticator(username: "username", password: "password", url: "url")
        XCTAssertNotNil(cp4d)

        // Verify that request headers can be set and retrieved
        cp4d.headers = ["X-custom-header": "my special value"]
        XCTAssertEqual(cp4d.headers!["X-custom-header"], "my special value")

        #if !os(Linux)
        // Verify that SSL verification can be disabled
        cp4d.disableSSLVerification()
        #endif
    }

    func testIAMAuthentication() {

        // To run this test:
        // 1. Set `IAMAuthentication.token` access level to `internal`
        // 2. Uncomment the code below
        // 3. Add credentials to TestCredentials.swift in Supporting Files folder
        // 4. Add TestCredentials.swift to the RestKitTests target

        // The `private` access level of the properties and functions in `IAMAuthentication` prohibit us from
        // modifying/calling them directly. As a result, this is hard to test properly (particularly token refresh).
        // One alternative would be to make the access level `internal` instead of `private`. Or we might be able to
        // build a `RestKit` framework and import it using `@testable RestKit` in order to access private members.

        /**

         let authenticator = IAMAuthenticator(apiKey: TestCredentials.IAMAPIKey, url: TestCredentials.IAMURL)
         var authorizationHeader: String! // save initial authorization header (it should stay the same until refreshed)
         request.authenticator = authenticator

         // request initial iam token
         let expectation1 = self.expectation(description: "request initial iam token")
         request.authenticator.authenticate(request: request) { request, error in
         guard let request = request, error == nil else { XCTFail(error!.localizedDescription); return }
         XCTAssertEqual(self.request.method, request.method)
         XCTAssertEqual(self.request.url, request.url)
         XCTAssertEqual(request.headerParameters["x-custom-header"], "value")
         XCTAssertTrue(request.headerParameters["Authorization"]!.starts(with: "Bearer "))
         XCTAssertEqual(self.request.queryItems, request.queryItems)
         XCTAssertEqual(self.request.messageBody, request.messageBody)
         authorizationHeader = request.headerParameters["Authorization"]!
         expectation1.fulfill()
         }
         wait(for: [expectation1], timeout: 5)

         sleep(1) // sleep for 1 second to make sure the unix time stamp increments

         // use the same iam token
         let expectation2 = self.expectation(description: "use the same iam token")
         request.authenticator.authenticate(request: request) { request, error in
         guard let request = request, error == nil else { XCTFail(error!.localizedDescription); return }
         XCTAssertEqual(request.headerParameters["Authorization"]!, authorizationHeader)
         expectation2.fulfill()
         }
         wait(for: [expectation2], timeout: 5)

         sleep(1) // sleep for 1 second to make sure the unix time stamp increments

         // change the token's expiration date to force a refresh
         let token = IAMToken(
         accessToken: authenticator.token!.accessToken,
         refreshToken: authenticator.token!.refreshToken,
         tokenType: authenticator.token!.tokenType,
         expiresIn: authenticator.token!.expiresIn,
         expiration: Int(Date().timeIntervalSince1970)
         )
         authenticator.token = token

         // refresh the iam token
         let expectation3 = self.expectation(description: "refresh the iam token")
         request.authenticator.authenticate(request: request) { request, error in
         guard let request = request, error == nil else { XCTFail(error!.localizedDescription); return }
         XCTAssertTrue(request.headerParameters["Authorization"]!.starts(with: "Bearer "))
         XCTAssertNotEqual(request.headerParameters["Authorization"]!, authorizationHeader)
         expectation3.fulfill()
         }
         wait(for: [expectation3], timeout: 5)

         */
    }

    func testCP4DTokenSource() {

        // To run this test:
        // 1. Uncomment the code below
        // 2. Create an CP4D instance and create credentials for the root user
        // 3. Add credentials to TestCredentials.swift in Supporting Files folder
        // 4. Add TestCredentials.swift to the RestKitTests target

        /*
        let expectation = self.expectation(description: "request token")
        // Edit /etc/hosts and add your cluster IP with the name `mycluster.icp`
        let tokenSource = CloudPakForDataTokenSource(username: TestCredentials.CP4DUsername, password: TestCredentials.CP4DPassword, url: TestCredentials.CP4DURL)
        tokenSource.disableSSLVerification()
        tokenSource.getToken { token, error in
            guard let token = token, error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            let expiration = JWT.getTokenExpiration(token: token)
            XCTAssertNotNil(expiration)
            XCTAssertGreaterThan(expiration?.timeIntervalSinceNow ?? 0, 0) // in the future
            XCTAssertLessThan(expiration?.timeIntervalSinceNow ?? 0, 60*60*24) // less than 1 day
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 25)
         */
    }

}
