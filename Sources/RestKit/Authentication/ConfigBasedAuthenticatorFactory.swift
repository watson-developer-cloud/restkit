/**
 * Copyright IBM Corporation 2019
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

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum AuthenticatorError: Error {
    case noConfigurationFound
    case authenticationTypeNotDefined
    case authenticationTypeNotRecognized
    case missingEnvironmentVariable(String)
}

public enum EnvironmentAuthenticatorType: String {
    case IAM = "iam"
    case basic = "basic"
    case CP4D = "cp4d"
    case noAuth = "noauth"
    case bearerToken = "bearerToken"
}

public enum EnvironmentAuthenticatorVariable: String {
    case authType = "auth_type"
    case username = "username"
    case password = "password"
    case apiKey = "apikey"
    case bearerToken = "bearer_token"
    case url = "url"
}

@available (iOS, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
@available (tvOS, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
@available (iOSMac, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
@available (watchOS, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
public struct ConfigBasedAuthenticatorFactory {
    @available(iOS 9.0, *)
    static public func getAuthenticator(credentialPrefix: String) throws -> Authenticator {
        guard let environmentVariables = ConfigBasedAuthenticatorFactory.getEnvironmentVariables(credentialPrefix: credentialPrefix) else {
           throw AuthenticatorError.noConfigurationFound
       }

        guard let authTypeEnvironmentVariable = environmentVariables[EnvironmentAuthenticatorVariable.authType.rawValue] else {
            throw AuthenticatorError.authenticationTypeNotDefined
        }

        guard let authenticatorType = EnvironmentAuthenticatorType(rawValue: authTypeEnvironmentVariable) else {
            throw AuthenticatorError.authenticationTypeNotRecognized
        }

        let authenticator = try ConfigBasedAuthenticatorFactory.buildAuthenticator(authenticatorType: authenticatorType, credentials: environmentVariables)
        return authenticator
    }

    static private func readEnvironmentFile(filePath: URL, credentialPrefix: String) -> [String: String]? {
        let environmentVariables: [String: String]? = Helpers.extractEnvironmentVariablesFromFile(environmentVariablePrefix: credentialPrefix, file: filePath)
        return environmentVariables
    }

    static private func readVCAPServicesVariables(credentialPrefix: String) -> [String: String]? {
        guard let vcapServicesEnvironmentVariable = ProcessInfo.processInfo.environment["VCAP_SERVICES"] else {
            return nil
        }

        let jsonData = try? JSONSerialization.jsonObject(with: vcapServicesEnvironmentVariable.data(using: .utf8)!, options: [])

        guard let parsedJsonData = jsonData as? [String: Any] else {
            return nil
        }

        if let selectedService = parsedJsonData[credentialPrefix] as? [Any] {
            if let firstServiceObject = selectedService.first as? [String: Any] {
                if let serviceCredentials = firstServiceObject["credentials"] as? [String: String] {
                    guard let authType = inferAuthType(credentials: serviceCredentials) else {
                        return nil
                    }

                    var updatedServiceCredentials = serviceCredentials
                    updatedServiceCredentials["auth_type"] = authType
                    return updatedServiceCredentials
                }
            }
        }

        return nil
    }

    static private func inferAuthType(credentials: [String: String]) -> String? {
        if credentials["apikey"] != nil || credentials["iam_apikey"] != nil {
            return EnvironmentAuthenticatorType.IAM.rawValue
        }

        if credentials["username"] != nil && credentials["password"] != nil {
            return EnvironmentAuthenticatorType.basic.rawValue
        }

        return nil
    }

    @available(iOS 9.0, *)
    static private func getEnvironmentVariables(credentialPrefix: String) -> [String: String]? {
        // first attempt to read local .env file
        let localEnvFile: URL = URL.init(fileURLWithPath: "ibm-credentials.env")
        if let localEnvironmentVariables: [String: String] = ConfigBasedAuthenticatorFactory.readEnvironmentFile(filePath: localEnvFile, credentialPrefix: credentialPrefix) {
            return localEnvironmentVariables
        }

        // look in user defined filepath for .env file
        if let userDefinedEnvFileName: String = ProcessInfo.processInfo.environment["IBM_CREDENTIALS_FILE"] {
            if FileManager.default.fileExists(atPath: userDefinedEnvFileName) && FileManager.default.isReadableFile(atPath: userDefinedEnvFileName) {
                let userDefinedEnvFile: URL = URL.init(fileURLWithPath: userDefinedEnvFileName)
                if let userSpecifiedEnvironmentVariables: [String: String] = ConfigBasedAuthenticatorFactory.readEnvironmentFile(filePath: userDefinedEnvFile, credentialPrefix: credentialPrefix) {
                    return userSpecifiedEnvironmentVariables
                }
            }
        }

        // look in the home directory for .env file
        let homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
        let homeDirectoryEnvFile: URL = URL.init(fileURLWithPath: "ibm-credentials.env", relativeTo: homeDirectory)
        if let homeDirectoryEnvironmentVariables: [String: String] = ConfigBasedAuthenticatorFactory.readEnvironmentFile(filePath: homeDirectoryEnvFile, credentialPrefix: credentialPrefix) {
            return homeDirectoryEnvironmentVariables
        }

        // look in VCAP_SERVICES (only available in CF environment)
        if let vcapServicesEnvironmentVariables: [String: String] = ConfigBasedAuthenticatorFactory.readVCAPServicesVariables(credentialPrefix: credentialPrefix) {
            return vcapServicesEnvironmentVariables
        }

        return nil
    }

    static private func buildAuthenticator(authenticatorType: EnvironmentAuthenticatorType, credentials: [String: String]) throws -> Authenticator {
        switch authenticatorType {
        case .basic:
            let basicAuth = try buildBasicAuthenticator(credentials: credentials)
            return basicAuth
        case .CP4D:
            let cp4dAuth = try buildCloudPakForDataAuthenticator(credentials: credentials)
            return cp4dAuth
        case .IAM:
            let iamAuth = try buildIAMAuthenticator(credentials: credentials)
            return iamAuth
        case .bearerToken:
            let tokenAuth = try buildTokenAuthenticator(credentials: credentials)
            return tokenAuth
        case .noAuth:
            let noAuth = NoAuthAuthenticator.init()
            return noAuth
        }
    }

    static private func buildBasicAuthenticator(credentials: [String: String]) throws -> BasicAuthenticator {
        guard let username = credentials[EnvironmentAuthenticatorVariable.username.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.username.rawValue)
        }

        guard let password = credentials[EnvironmentAuthenticatorVariable.password.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.password.rawValue)
        }

        let basicAuthenticator = BasicAuthenticator.init(username: username, password: password)
        return basicAuthenticator
    }

    static private func buildIAMAuthenticator(credentials: [String: String]) throws -> IAMAuthenticator {
        guard let apikey = credentials[EnvironmentAuthenticatorVariable.apiKey.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.apiKey.rawValue)
        }

        let iamAuthenticator = IAMAuthenticator.init(apiKey: apikey)
        return iamAuthenticator
    }

    static private func buildTokenAuthenticator(credentials: [String: String]) throws -> BearerTokenAuthenticator {
        guard let bearerToken = credentials[EnvironmentAuthenticatorVariable.bearerToken.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.bearerToken.rawValue)
        }

        let tokenAuthenticator = BearerTokenAuthenticator.init(bearerToken: bearerToken)
        return tokenAuthenticator
    }

    static private func buildCloudPakForDataAuthenticator(credentials: [String: String]) throws -> CloudPakForDataAuthenticator {
        guard let username = credentials[EnvironmentAuthenticatorVariable.username.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.username.rawValue)
        }

        guard let password = credentials[EnvironmentAuthenticatorVariable.password.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.password.rawValue)
        }

        guard let url = credentials[EnvironmentAuthenticatorVariable.url.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.url.rawValue)
        }

        let cp4dAuthenticator = CloudPakForDataAuthenticator.init(username: username, password: password, url: url)
        return cp4dAuthenticator
    }
}
