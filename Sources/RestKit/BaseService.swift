/**
 * (C) Copyright IBM Corp. 2019.
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

public protocol ServiceClient {
    var serviceURL: String? { get set }
    var authenticator: Authenticator { get }
    var session: URLSession { get set }
    var defaultHeaders: [String: String] { get set }
}

open class BaseService: ServiceClient {
    public var serviceURL: String?
    public var authenticator: Authenticator
    public var defaultHeaders: [String: String]
    public var session: URLSession

    public init(authenticator: Authenticator) {
        self.authenticator = authenticator
        self.defaultHeaders = [String: String]()
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }
}
