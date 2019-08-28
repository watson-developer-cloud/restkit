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

class ConfigBasedAuthenticatorFactoryTests: XCTestCase {

    static var allTests = [
        ("testGetBasicAuthFromLocalEnv", testGetBasicAuthFromLocalEnv),
        ("testGetIAMAuthFromLocalEnv", testGetIAMAuthFromLocalEnv),
        ("testGetCP4DAuthFromLocalEnv", testGetCP4DAuthFromLocalEnv),
        ("testGetBearerTokenAuthFromLocalEnv", testGetBearerTokenAuthFromLocalEnv),
        ("testGetNoauthFromLocalEnv", testGetNoauthFromLocalEnv),
        ("testGetBasicAuthFromHomeDirectoryEnv", testGetBasicAuthFromHomeDirectoryEnv),
        ("testGetIAMAuthFromHomeDirectoryEnv", testGetIAMAuthFromHomeDirectoryEnv),
        ("testGetCP4DAuthFromHomeDirectoryEnv", testGetCP4DAuthFromHomeDirectoryEnv),
        ("testGetBearerTokenAuthFromHomeDirectoryEnv", testGetBearerTokenAuthFromHomeDirectoryEnv),
        ("testGetNoauthFromHomeDirectoryEnv", testGetNoauthFromHomeDirectoryEnv),
        ("testGetBasicAuthFromUserDefinedDirectoryEnv", testGetBasicAuthFromUserDefinedLocationEnv),
        ("testGetIAMAuthFromUserDefinedDirectoryEnv", testGetIAMAuthFromUserDefinedLocationEnv),
        ("testGetCP4DAuthFromUserDefinedDirectoryEnv", testGetCP4DAuthFromUserDefinedDirectoryEnv),
        ("testGetBearerTokenAuthFromUserDefinedDirectoryEnv", testGetBearerTokenAuthFromUserDefinedDirectoryEnv),
        ("testGetNoauthFromUserDefinedDirectoryEnv", testGetNoauthFromUserDefinedDirectoryEnv),
        ("testGetBasicAuthFromVcapServices", testGetBasicAuthFromVcapServices),
        ("testGetIAMAuthFromVcapServices", testGetIAMAuthFromVcapServices),
        ("testAllAuthsThrowErrorIfRequiredVariableMissing", testAllAuthsThrowErrorIfRequiredVariableMissing),
        ("testAllAuthsThrowErrorIfAuthTypeUndefined", testAllAuthsThrowErrorIfAuthTypeUndefined),
        ("testAllAuthsThrowErrorIfUnrecognizedAuthType", testAllAuthsThrowErrorIfUnrecognizedAuthType),
    ]

    let workingDirectory = FileManager.default.currentDirectoryPath + "/ibm-credentials.env"
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.relativePath + "/ibm-credentials.env"

    // MARK: Env File Mocks

    let mockBasicAuthEnv: Data? = """
    SERVICE_1_USERNAME=asdf
    SERVICE_1_PASSWORD=hunter2
    SERVICE_1_AUTH_TYPE=basic
    """.data(using: .utf8)

    let mockIAMAuthEnv: Data? = """
    SERVICE_1_APIKEY=asdf
    SERVICE_1_AUTH_TYPE=iam
    """.data(using: .utf8)

    let mockCP4DAuthEnv: Data? = """
    SERVICE_1_USERNAME=cp4d
    SERVICE_1_PASSWORD=hunter2
    SERVICE_1_URL=https://asdf.com
    SERVICE_1_AUTH_TYPE=cp4d
    """.data(using: .utf8)

    let mockBearerTokenAuthEnv: Data? = """
    SERVICE_1_BEARER_TOKEN=c4dasd432asdj3
    SERVICE_1_AUTH_TYPE=bearerToken
    """.data(using: .utf8)

    let mockNoAuthEnv: Data? = """
    SERVICE_1_AUTH_TYPE=noauth
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

    func testGetBasicAuthFromLocalEnv() {
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockBasicAuthEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        debugPrint(workingDirectory)
        debugPrint(homeDirectory)

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is BasicAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetIAMAuthFromLocalEnv() {
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockIAMAuthEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is IAMAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetCP4DAuthFromLocalEnv() {
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockCP4DAuthEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is CloudPakForDataAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetBearerTokenAuthFromLocalEnv() {
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockBearerTokenAuthEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is BearerTokenAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetNoauthFromLocalEnv() {
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockNoAuthEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is NoAuthAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    // MARK: Home directory .env tests

    func testGetBasicAuthFromHomeDirectoryEnv() {
        if FileManager.default.createFile(atPath: homeDirectory, contents: mockBasicAuthEnv) == false {
            XCTFail("Failed to create mock home directory .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is BasicAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetIAMAuthFromHomeDirectoryEnv() {
        if FileManager.default.createFile(atPath: homeDirectory, contents: mockIAMAuthEnv) == false {
            XCTFail("Failed to create mock home directory .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is IAMAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetCP4DAuthFromHomeDirectoryEnv() {
        if FileManager.default.createFile(atPath: homeDirectory, contents: mockCP4DAuthEnv) == false {
            XCTFail("Failed to create mock home directory .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is CloudPakForDataAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetBearerTokenAuthFromHomeDirectoryEnv() {
        if FileManager.default.createFile(atPath: homeDirectory, contents: mockBearerTokenAuthEnv) == false {
            XCTFail("Failed to create mock home directory .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is BearerTokenAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetNoauthFromHomeDirectoryEnv() {
        if FileManager.default.createFile(atPath: homeDirectory, contents: mockNoAuthEnv) == false {
            XCTFail("Failed to create mock home directory .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is NoAuthAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    // MARK: User defined location .env tests

    func testGetBasicAuthFromUserDefinedLocationEnv() {
        guard let userDefinedDirectory = ProcessInfo.processInfo.environment["IBM_CREDENTIALS_FILE"] else {
            XCTFail("IBM_CREDENTIALS_FILE is not defined in the test environment")
            return
        }

        if FileManager.default.createFile(atPath: userDefinedDirectory, contents: mockBasicAuthEnv) == false {
            XCTFail("Failed to create mock user defined .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is BasicAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetIAMAuthFromUserDefinedLocationEnv() {
        guard let userDefinedDirectory = ProcessInfo.processInfo.environment["IBM_CREDENTIALS_FILE"] else {
            XCTFail("IBM_CREDENTIALS_FILE is not defined in the test environment")
            return
        }

        if FileManager.default.createFile(atPath: userDefinedDirectory, contents: mockIAMAuthEnv) == false {
            XCTFail("Failed to create mock user defined directory .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is IAMAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetCP4DAuthFromUserDefinedDirectoryEnv() {
        guard let userDefinedDirectory = ProcessInfo.processInfo.environment["IBM_CREDENTIALS_FILE"] else {
            XCTFail("IBM_CREDENTIALS_FILE is not defined in the test environment")
            return
        }

        if FileManager.default.createFile(atPath: userDefinedDirectory, contents: mockCP4DAuthEnv) == false {
            XCTFail("Failed to create mock user defined directory .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is CloudPakForDataAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetBearerTokenAuthFromUserDefinedDirectoryEnv() {
        guard let userDefinedDirectory = ProcessInfo.processInfo.environment["IBM_CREDENTIALS_FILE"] else {
            XCTFail("IBM_CREDENTIALS_FILE is not defined in the test environment")
            return
        }

        if FileManager.default.createFile(atPath: userDefinedDirectory, contents: mockBearerTokenAuthEnv) == false {
            XCTFail("Failed to create mock user defined directory .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is BearerTokenAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetNoauthFromUserDefinedDirectoryEnv() {
        guard let userDefinedDirectory = ProcessInfo.processInfo.environment["IBM_CREDENTIALS_FILE"] else {
            XCTFail("IBM_CREDENTIALS_FILE is not defined in the test environment")
            return
        }

        if FileManager.default.createFile(atPath: userDefinedDirectory, contents: mockNoAuthEnv) == false {
            XCTFail("Failed to create mock user defined directory .env file")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1")
            XCTAssert(authenticator is NoAuthAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    // MARK: VCAP_SERVICES defined auth

    func testGetBasicAuthFromVcapServices() {
        if ProcessInfo.processInfo.environment["VCAP_SERVICES"] == nil {
            XCTFail("VCAP_SERVICES is not defined in the test environment")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "service1")
            XCTAssert(authenticator is BasicAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testGetIAMAuthFromVcapServices() {
        if ProcessInfo.processInfo.environment["VCAP_SERVICES"] == nil {
            XCTFail("VCAP_SERVICES is not defined in the test environment")
        }

        do {
            let authenticator: Authenticator = try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "service2")
            XCTAssert(authenticator is IAMAuthenticator)
        } catch AuthenticatorError.noConfigurationFound {
            XCTFail("No configuration file found")
        } catch AuthenticatorError.authenticationTypeNotDefined {
            XCTFail("auth type is not defined")
        } catch AuthenticatorError.authenticationTypeNotRecognized {
            XCTFail("auth type not recognized")
        } catch AuthenticatorError.missingEnvironmentVariable(let missingVariable) {
            XCTFail("missing required environment variable \(missingVariable)")
        } catch {
            XCTFail("Unknown error")
        }
    }

    // MARK: Error state tests

    func testAllAuthsThrowErrorIfRequiredVariableMissing() {
        let mockMalformedBasicEnv: Data? = """
        SERVICE_1_PASSWORD=hunter2
        SERVICE_1_AUTH_TYPE=basic
        """.data(using: .utf8)

        let mockMalformedIAMEnv: Data? = """
        SERVICE_1_AUTH_TYPE=iam
        """.data(using: .utf8)

        let mockMalFormedCP4DEnv: Data? = """
        SERVICE_1_PASSWORD=hunter2
        SERVICE_1_URL=https://asdf.com
        SERVICE_1_AUTH_TYPE=cp4d
        """.data(using: .utf8)

        let mockMalformedBearerTokenEnv: Data? = """
        SERVICE_1_AUTH_TYPE=bearerToken
        """.data(using: .utf8)

        // Test basic auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalformedBasicEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)

        // Test IAM auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalformedIAMEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)

        // Test CP4D auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalFormedCP4DEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)

        // Test BearerToken auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalformedBearerTokenEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)
    }

    func testAllAuthsThrowErrorIfAuthTypeUndefined() {
        let mockMalformedBasicEnv: Data? = """
        SERVICE_1_USERNAME=basic
        SERVICE_1_PASSWORD=hunter2
        """.data(using: .utf8)

        let mockMalformedIAMEnv: Data? = """
        SERVICE_1_APIKEY=asdf38asdf8j
        """.data(using: .utf8)

        let mockMalFormedCP4DEnv: Data? = """
        SERVICE_1_USERNAME=cp4d
        SERVICE_1_PASSWORD=hunter2
        SERVICE_1_URL=https://asdf.com
        """.data(using: .utf8)

        let mockMalformedBearerTokenEnv: Data? = """
        SERVICE_1_BEARER_TOKEN=cp4d
        """.data(using: .utf8)

        // Test basic auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalformedBasicEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)

        // Test IAM auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalformedIAMEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)

        // Test CP4D auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalFormedCP4DEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)

        // Test BearerToken auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalformedBearerTokenEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)
    }

    func testAllAuthsThrowErrorIfUnrecognizedAuthType() {
        let mockMalformedBasicEnv: Data? = """
        SERVICE_1_USERNAME=basic
        SERVICE_1_PASSWORD=hunter2
        SERVICE_1_AUTH_TYPE=badnews
        """.data(using: .utf8)

        let mockMalformedIAMEnv: Data? = """
        SERVICE_1_APIKEY=asdf38asdf8j
        SERVICE_1_AUTH_TYPE=badnews
        """.data(using: .utf8)

        let mockMalFormedCP4DEnv: Data? = """
        SERVICE_1_USERNAME=cp4d
        SERVICE_1_PASSWORD=hunter2
        SERVICE_1_URL=https://asdf.com
        SERVICE_1_AUTH_TYPE=badnews
        """.data(using: .utf8)

        let mockMalformedBearerTokenEnv: Data? = """
        SERVICE_1_BEARER_TOKEN=cp4d
        SERVICE_1_AUTH_TYPE=badnews
        """.data(using: .utf8)

        // Test basic auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalformedBasicEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)

        // Test IAM auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalformedIAMEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)

        // Test CP4D auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalFormedCP4DEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)

        // Test BearerToken auth
        if FileManager.default.createFile(atPath: workingDirectory, contents: mockMalformedBearerTokenEnv) == false {
            XCTFail("Failed to create mock local .env file")
        }

        XCTAssertThrowsError(try ConfigBasedAuthenticatorFactory.getAuthenticator(credentialPrefix: "SERVICE_1"))

        deleteMockFile(path: workingDirectory)
    }
}
#endif
