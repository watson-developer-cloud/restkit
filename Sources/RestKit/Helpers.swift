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

public struct Helpers {
    static func extractEnvironmentVariablesFromFile(environmentVariablePrefix: String, file: URL) -> [String : String]? {
        guard let fileLines = try? String(contentsOf: file).components(separatedBy: .newlines) else {
            return nil
        }
        
        // Turn each credential into a key/value pair
        let serviceCredentials = fileLines
            .filter { $0.lowercased().starts(with: environmentVariablePrefix.lowercased()) }
            .reduce([:]) { (result, credentialLine) -> [String: String] in
                let credentials = credentialLine.split(separator: "=", maxSplits: 1)
                let lowerCaseKey = credentials[0].lowercased()
                let removalIndex = lowerCaseKey.index(lowerCaseKey.startIndex, offsetBy: environmentVariablePrefix.count + 1)
                let key = String(lowerCaseKey[removalIndex...])
                let value = String(credentials[1])
                
                return result.merging([key: value]) { (_, new) in new }
        }
        return serviceCredentials
    }
}
