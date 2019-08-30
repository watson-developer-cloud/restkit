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

#if os(Linux)
import XCTest
import RestKit

class CredentialUtilsTests: XCTestCase {

    static var allTests = [
        ("testGetEnvironmentVariablesFromLocalEnv", testGetEnvironmentVariablesFromLocalEnv),
        ("testGetServiceURLFromLocalEnv", testGetServiceURLFromLocalEnv),
        ("testGetEnvironmentVariablesFromHomeDirectoryEnv", testGetEnvironmentVariablesFromHomeDirectoryEnv),
        ("testGetServiceURLFromHomeDirectoryEnv", testGetServiceURLFromHomeDirectoryEnv),
        ("testGetEnvironmentVariablesFromUserDefinedLocationEnv", testGetEnvironmentVariablesFromUserDefinedLocationEnv),
        ("testGetServiceURLFromUserDefinedLocationEnv", testGetServiceURLFromUserDefinedLocationEnv),
        ("testGetEnvironmentVariablesFromVcapServices", testGetEnvironmentVariablesFromVcapServices)
    ]

    let workingDirectory = FileManager.default.currentDirectoryPath + "/ibm-credentials.env"
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.relativePath + "/ibm-credentials.env"

    // MARK: Env File Mocks

    let mockBasicAuthEnv: Data? = """
    SERVICE_1_USERNAME=asdf
    SERVICE_1_PASSWORD=hunter2
    SERVICE_1_AUTH_TYPE=basic
    SERVICE_1_SERVICE_URL=http://asdf.com
    """.data(using: .utf8)

    // MARK: Test helper functions
    func deleteMockFile(path: String) {
        if FileManager.default.fileExists(atPath: path) {
            guard let _ = try? FileManager.default.removeItem(atPath: path) else {
                debugPrint("Attempt to delete environment file at path \(path) failed")
                return
            }
        }
    }

    // MARK: Tests

    override func tearDown() {
        deleteMockFile(path: workingDirectory)
        deleteMockFile(path: homeDirectory)

        if let userDefinedDirectory = ProcessInfo.processInfo.environment["IBM_CREDENTIALS_FILE"] {
            deleteMockFile(path: userDefinedDirectory)
        }
    }

    // MARK: Local .env tests

    func testGetEnvironmentVariablesFromLocalEnv() {
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockBasicAuthEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        let result = CredentialUtils.getEnvironmentVariables(credentialPrefix: "SERVICE_1")
        XCTAssertNotNil(result)
    }

    func testGetServiceURLFromLocalEnv() {
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockBasicAuthEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        let expected = "http://asdf.com"
        let result = CredentialUtils.getServiceURL(credentialPrefix: "SERVICE_1")
        XCTAssert(expected == result)
    }

    // MARK: Home directory .env tests

    func testGetEnvironmentVariablesFromHomeDirectoryEnv() {
        if FileManager.default.createFile(atPath: homeDirectory, contents: mockBasicAuthEnv) == false {
            XCTFail("Failed to create mock home directory .env file")
        }

        let result = CredentialUtils.getEnvironmentVariables(credentialPrefix: "SERVICE_1")
        XCTAssertNotNil(result)
    }

    func testGetServiceURLFromHomeDirectoryEnv() {
        if FileManager.default.createFile(atPath: homeDirectory, contents: mockBasicAuthEnv) == false {
            XCTFail("Failed to create mock home directory .env file")
        }

        let expected = "http://asdf.com"
        let result = CredentialUtils.getServiceURL(credentialPrefix: "SERVICE_1")
        XCTAssert(expected == result)
    }

    // MARK: User defined directory .env tests

    func testGetEnvironmentVariablesFromUserDefinedLocationEnv() {
        guard let userDefinedDirectory = ProcessInfo.processInfo.environment["IBM_CREDENTIALS_FILE"] else {
            XCTFail("IBM_CREDENTIALS_FILE is not defined in the test environment")
            return
        }

        if FileManager.default.createFile(atPath: userDefinedDirectory, contents: mockBasicAuthEnv) == false {
            XCTFail("Failed to create mock user defined .env file")
        }

        let result = CredentialUtils.getEnvironmentVariables(credentialPrefix: "SERVICE_1")
        XCTAssertNotNil(result)
    }

    func testGetServiceURLFromUserDefinedLocationEnv() {
        guard let userDefinedDirectory = ProcessInfo.processInfo.environment["IBM_CREDENTIALS_FILE"] else {
            XCTFail("IBM_CREDENTIALS_FILE is not defined in the test environment")
            return
        }

        if FileManager.default.createFile(atPath: userDefinedDirectory, contents: mockBasicAuthEnv) == false {
            XCTFail("Failed to create mock user defined .env file")
        }

        let expected = "http://asdf.com"
        let result = CredentialUtils.getServiceURL(credentialPrefix: "SERVICE_1")
        XCTAssert(expected == result)
    }

    // MARK: VCAP_SERVICES .env tests

    func testGetEnvironmentVariablesFromVcapServices() {
        if ProcessInfo.processInfo.environment["VCAP_SERVICES"] == nil {
            XCTFail("VCAP_SERVICES is not defined in the test environment")
        }

        let result = CredentialUtils.getEnvironmentVariables(credentialPrefix: "service1")
        XCTAssertNotNil(result)
    }
}
#endif
