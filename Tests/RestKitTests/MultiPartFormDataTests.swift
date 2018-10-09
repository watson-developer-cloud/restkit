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

// swiftlint:disable function_body_length force_try force_unwrapping file_length

import XCTest
@testable import RestKit

class MultiPartFormDataTests: XCTestCase {

    static var allTests = [
        ("testSimpleFormData", testSimpleFormData),
        ("testFormData", testFormData),
        ("testFormDataFromURL", testFormDataFromURL),
        ("testFormDataWithInvalidURL", testFormDataWithInvalidURL)
    ]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func loadResource(name: String, ext: String) -> URL {
        #if os(Linux)
        return URL(fileURLWithPath: "Tests/Resources/" + name + "." + ext)
        #else
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            XCTFail("Unable to locate resource.")
            assert(false)
        }
        return url
        #endif
    }

    // MARK: - MultipartFormData tests

    func testSimpleFormData() {
        let field1Data = "This is test data for field1".data(using: .utf8)!
        let multipartFormData = MultipartFormData()
        multipartFormData.append(field1Data, withName: "field1")
        XCTAssertEqual(1, multipartFormData.bodyParts.count)
        XCTAssertEqual("field1", multipartFormData.bodyParts[0].key)
    }

    func testFormData() {
        let htmlData = "<html><body><h1>This is test html data</h1></body></html>".data(using: .utf8)!
        let multipartFormData = MultipartFormData()
        multipartFormData.append(htmlData, withName: "html", mimeType: "text/html", fileName: "test.html")
        XCTAssertEqual(1, multipartFormData.bodyParts.count)
        XCTAssertEqual("html", multipartFormData.bodyParts[0].key)
        XCTAssertEqual("text/html", multipartFormData.bodyParts[0].mimeType)
        XCTAssertEqual("test.html", multipartFormData.bodyParts[0].fileName)
    }

    func testFormDataFromURL() {
        let testDataFile = loadResource(name: "TestData", ext: "txt")
        let multipartFormData = MultipartFormData()
        multipartFormData.append(testDataFile, withName: "test_data", mimeType: "application/octet-stream")
        XCTAssertEqual(1, multipartFormData.bodyParts.count)
        XCTAssertEqual("test_data", multipartFormData.bodyParts[0].key)
        XCTAssertEqual("application/octet-stream", multipartFormData.bodyParts[0].mimeType)
        XCTAssertEqual("TestData.txt", multipartFormData.bodyParts[0].fileName)
    }

    func testFormDataWithInvalidURL() {
        let testDataFile = URL(string: "https://x.y.z/this/isnt/valid")!
        let multipartFormData = MultipartFormData()
        // append with invalid fileURL should throw
        XCTAssertThrowsError(try multipartFormData.append(file: testDataFile, withName: "test_data", mimeType: "application/octet-stream"))
    }

}
