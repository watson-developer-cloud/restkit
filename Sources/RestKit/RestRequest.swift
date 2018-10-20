/**
 * Copyright IBM Corporation 2016-2017
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

// MARK: - RestRequest

public struct RestRequest {

    // TODO: For RestKit version 2.0, remove the setter. This should only be set by the Watson Swift SDK.
    // This needs to stay until 2.0 because Carthage will cause it to break with Watson Swift SDK v0.33.
    /// The "User-Agent" header that will be sent with every network request
    /// This can include information such as the operating system and the SDK/framework calling this API
    public static var userAgent: String = {
        let sdk = "watson-apis-swift-sdk"

        let operatingSystem: String = {
            #if os(iOS)
            return "iOS"
            #elseif os(watchOS)
            return "watchOS"
            #elseif os(tvOS)
            return "tvOS"
            #elseif os(macOS)
            return "macOS"
            #elseif os(Linux)
            return "Linux"
            #else
            return "Unknown"
            #endif
        }()
        let operatingSystemVersion: String = {
            // swiftlint:disable:next identifier_name
            let os = ProcessInfo.processInfo.operatingSystemVersion
            return "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        }()
        return "\(sdk)/\(sdkVersion) \(operatingSystem)/\(operatingSystemVersion)"
    }()

    // TODO: Remove this in RestKit version 2.0
    public static var sdkVersion: String = "0.33.0"

    private let session: URLSession
    internal var authMethod: AuthenticationMethod
    internal var errorResponseDecoder: ((Data, HTTPURLResponse) -> RestError)
    internal var method: String
    internal var url: String
    internal var headerParameters: [String: String]
    internal var queryItems: [URLQueryItem]
    internal var messageBody: Data?

    public init(
        session: URLSession,
        authMethod: AuthenticationMethod,
        errorResponseDecoder: @escaping ((Data, HTTPURLResponse) -> RestError),
        method: String,
        url: String,
        headerParameters: [String: String],
        queryItems: [URLQueryItem]? = nil,
        messageBody: Data? = nil)
    {
        self.session = session
        self.authMethod = authMethod
        self.errorResponseDecoder = errorResponseDecoder
        self.method = method
        self.url = url
        self.headerParameters = headerParameters
        self.queryItems = queryItems ?? []
        self.messageBody = messageBody
    }

    private var urlRequest: URLRequest? {
        guard var components = URLComponents(string: url) else {
            return nil
        }
        if !queryItems.isEmpty { components.queryItems = queryItems }
        // we must explicitly encode "+" as "%2B" since URLComponents does not
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        guard let urlWithQuery = components.url else {
            return nil
        }
        var request = URLRequest(url: urlWithQuery)
        request.httpMethod = method
        request.httpBody = messageBody
        request.setValue(RestRequest.userAgent, forHTTPHeaderField: "User-Agent")
        headerParameters.forEach { (key, value) in request.setValue(value, forHTTPHeaderField: key) }
        return request
    }
}

// MARK: - Response Functions

extension RestRequest {

    /**
     Execute this request. (This is called by many of the functions below.)

     - completionHandler: The completion handler to call when the request is complete.
     */
    internal func execute(
        completionHandler: @escaping (Data?, HTTPURLResponse?, RestError?) -> Void)
    {
        // add authentication credentials to the request
        authMethod.authenticate(request: self) { request, error in

            // ensure there is no credentials error
            guard let request = request, error == nil else {
                completionHandler(nil, nil, error)
                return
            }

            // ensure there is no credentials error
            guard let urlRequest = request.urlRequest else {
                completionHandler(nil, nil, RestError.badURL)
                return
            }

            // create a task to execute the request
            let task = self.session.dataTask(with: urlRequest) { (data, response, error) in

                // ensure there is a valid http response
                guard let response = response as? HTTPURLResponse else {
                    let error = RestError.noResponse
                    completionHandler(data, nil, error)
                    return
                }

                // ensure there is no underlying error
                guard error == nil else {
                    let restError = RestError.http(statusCode: response.statusCode, message: "\(String(describing: error))", metadata: nil)
                    completionHandler(data, response, restError)
                    return
                }

                // ensure the status code is successful
                guard (200..<300).contains(response.statusCode) else {
                    if let data = data {
                        let serviceError = self.errorResponseDecoder(data, response)
                        completionHandler(data, response, serviceError)
                    } else {
                        let genericMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                        let genericError = RestError.http(statusCode: response.statusCode, message: genericMessage, metadata: nil)
                        completionHandler(data, response, genericError)
                    }
                    return
                }

                // execute completion handler with successful response
                completionHandler(data, response, nil)
            }

            // start the task
            task.resume()
        }
    }

    /**
     Execute this request and process the response body as raw data.

     - completionHandler: The completion handler to call when the request is complete.
     */
    public func response<T>(
        completionHandler: @escaping (WatsonResponse<T>?, RestError?) -> Void)
    {
        // execute the request
        execute { data, response, error in

            // ensure there is no underlying error
            guard let response = response, error == nil else {
                completionHandler(nil, error ?? RestError.noResponse)
                return
            }

            var watsonResponse = WatsonResponse<T>(response: response)

            // ensure there is data to parse
            guard let data = data else {
                completionHandler(watsonResponse, RestError.noData)
                return
            }

            if T.self == Data.self {
                // pass thru the raw data
                watsonResponse.result = data as? T
            } else if T.self == String.self {
                // parse data as a string
                guard let string = String(data: data, encoding: .utf8) else {
                    completionHandler(watsonResponse, RestError.serialization(values: "response string"))
                    return
                }
                watsonResponse.result = string as? T
            } else {
                // no other supported types
                watsonResponse.result = nil
            }

            // execute completion handler
            completionHandler(watsonResponse, nil)
        }
    }

    /**
     Execute this request and process the response body as a JSON object.

     - completionHandler: The completion handler to call when the request is complete.
     */
    public func responseObject<T: Decodable>(
        completionHandler: @escaping (WatsonResponse<T>?, RestError?) -> Void)
    {
        // execute the request
        execute { data, response, error in

            // ensure there is no underlying error
            guard let response = response, error == nil else {
                completionHandler(nil, error ?? RestError.noResponse)
                return
            }

            var watsonResponse = WatsonResponse<T>(response: response)

            // ensure there is data to parse
            guard let data = data else {
                completionHandler(watsonResponse, RestError.noData)
                return
            }

            // parse response body as a JSONobject
            do {
                watsonResponse.result = try JSON.decoder.decode(T.self, from: data)
                completionHandler(watsonResponse, nil)
            } catch {
                completionHandler(nil, RestError.serialization(values: "response JSON"))
            }
        }
    }

    /**
     Execute this request and ignore any response body.

     - completionHandler: The completion handler to call when the request is complete.
     */
    public func responseVoid(
        completionHandler: @escaping (WatsonResponse<Void>?, RestError?) -> Void)
    {
        // execute the request
        execute { _, response, error in

            // ensure there is no underlying error
            guard let response = response, error == nil else {
                completionHandler(nil, error ?? RestError.noResponse)
                return
            }

            let watsonResponse = WatsonResponse<Void>(response: response)

            // execute completion handler
            completionHandler(watsonResponse, nil)
        }
    }

    /**
     Execute this request and save the response body to disk.

     - to: The destination file where the response body should be saved.
     - completionHandler: The completion handler to call when the request is complete.
     */
    public func download(
        to destination: URL,
        completionHandler: @escaping (HTTPURLResponse?, RestError?) -> Void)
    {
        // add authentication credentials to the request
        authMethod.authenticate(request: self) { request, error in

            // ensure there is no credentials error
            guard let request = request, error == nil else {
                completionHandler(nil, error)
                return
            }

            // ensure there is no credentials error
            guard let urlRequest = request.urlRequest else {
                completionHandler(nil, RestError.badURL)
                return
            }

            // create a task to execute the request
            let task = self.session.downloadTask(with: urlRequest) { (location, response, error) in

                // ensure there is a valid http response
                guard let response = response as? HTTPURLResponse else {
                    completionHandler(nil, RestError.noResponse)
                    return
                }

                // ensure there is no underlying error
                guard error == nil else {
                    let restError = RestError.http(statusCode: response.statusCode, message: "\(String(describing: error))", metadata: nil)
                    completionHandler(response, restError)
                    return
                }

                // ensure that we can retrieve the downloaded data from its temporary location
                guard let location = location else {
                    completionHandler(response, RestError.noData)
                    return
                }

                // move the temporary file to the specified destination
                do {
                    try FileManager.default.moveItem(at: location, to: destination)
                    completionHandler(response, nil)
                } catch {
                    completionHandler(response, RestError.saveData)
                }
            }

            // start the download task
            task.resume()
        }
    }
}
