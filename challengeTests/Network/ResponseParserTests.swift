//
//  ResponseParserTests.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class ResponseParserTests: XCTestCase {

    // MARK: - Properties

    var sut: ResponseParser!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = ResponseParser()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Successful Response Tests

    func test_parse_whenSuccessfulResponse_shouldReturnDecodedObject() throws {
        // Given
        let request = MockDecodableRequest()
        let jsonData = """
        {
            "id": "123",
            "title": "iPhone 15",
            "price": 999.99
        }
        """.data(using: .utf8)!

        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        // When
        let result: MockProduct = try sut.parse(request, data: jsonData, urlResponse: httpResponse)

        // Then
        XCTAssertEqual(result.id, "123", "correctly decodes id")
        XCTAssertEqual(result.title, "iPhone 15", "correctly decodes title")
        XCTAssertEqual(result.price, 999.99, "correctly decodes price")
    }

    func test_parse_when201Created_shouldReturnDecodedObject() throws {
        // Given
        let request = MockDecodableRequest()
        let jsonData = """
        {
            "id": "456",
            "title": "MacBook",
            "price": 1999.99
        }
        """.data(using: .utf8)!

        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )!

        // When
        let result: MockProduct = try sut.parse(request, data: jsonData, urlResponse: httpResponse)

        // Then
        XCTAssertEqual(result.id, "456", "correctly decodes created object")
    }

    // MARK: - Error Response Tests

    func test_parse_when401Unauthorized_shouldThrowAPIError() {
        // Given
        let request = MockDecodableRequest()
        let errorData = """
        {
            "message": "Unauthorized",
            "code": "unauthorized"
        }
        """.data(using: .utf8)!

        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!

        // When / Then
        XCTAssertThrowsError(try sut.parse(request, data: errorData, urlResponse: httpResponse)) { error in
            if case APIError.apiError(_, let statusCode) = error {
                XCTAssertEqual(statusCode, 401, "includes statusCode 401")
            } else {
                XCTFail("should throw APIError.apiError")
            }
        }
    }

    func test_parse_when404NotFound_shouldThrowAPIError() {
        // Given
        let request = MockDecodableRequest()
        let errorData = """
        {
            "message": "Resource not found",
            "code": "resource not found"
        }
        """.data(using: .utf8)!

        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!

        // When / Then
        XCTAssertThrowsError(try sut.parse(request, data: errorData, urlResponse: httpResponse)) { error in
            if case APIError.apiError(_, let statusCode) = error {
                XCTAssertEqual(statusCode, 404, "includes statusCode 404")
            } else {
                XCTFail("should throw APIError.apiError")
            }
        }
    }

    func test_parse_when500ServerError_shouldThrowHTTPError() {
        // Given
        let request = MockDecodableRequest()
        let errorData = "Internal Server Error".data(using: .utf8)!

        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!

        // When / Then
        XCTAssertThrowsError(try sut.parse(request, data: errorData, urlResponse: httpResponse)) { error in
            if case APIError.httpError(let statusCode) = error {
                XCTAssertEqual(statusCode, 500, "includes statusCode 500")
            } else {
                XCTFail("should throw APIError.httpError")
            }
        }
    }

    // MARK: - Decoding Error Tests

    func test_parse_whenInvalidJSON_shouldThrowDecodingError() {
        // Given
        let request = MockDecodableRequest()
        let invalidData = "{ invalid json }".data(using: .utf8)!

        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        // When / Then
        XCTAssertThrowsError(try sut.parse(request, data: invalidData, urlResponse: httpResponse)) { error in
            if case APIError.decodingFailed(_, let statusCode) = error {
                XCTAssertEqual(statusCode, 200, "includes statusCode in error")
            } else {
                XCTFail("should throw APIError.decodingFailed")
            }
        }
    }

    func test_parse_whenMissingRequiredField_shouldThrowDecodingError() {
        // Given
        let request = MockDecodableRequest()
        let incompleteData = """
        {
            "id": "123"
        }
        """.data(using: .utf8)!

        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        // When / Then
        XCTAssertThrowsError(try sut.parse(request, data: incompleteData, urlResponse: httpResponse)) { error in
            if case APIError.decodingFailed = error {
                // OK
            } else {
                XCTFail("should throw APIError.decodingFailed")
            }
        }
    }

    func test_parse_whenWrongDataType_shouldThrowDecodingError() {
        // Given
        let request = MockDecodableRequest()
        let wrongTypeData = """
        {
            "id": "123",
            "title": "iPhone",
            "price": "not_a_number"
        }
        """.data(using: .utf8)!

        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        // When / Then
        XCTAssertThrowsError(try sut.parse(request, data: wrongTypeData, urlResponse: httpResponse)) { error in
            if case APIError.decodingFailed = error {
                // OK
            } else {
                XCTFail("should throw APIError.decodingFailed")
            }
        }
    }

    // MARK: - Local File Response Tests

    func test_parse_whenLocalFileURL_shouldDecodeSuccessfully() throws {
        // Given
        let request = MockDecodableRequest()
        let jsonData = """
        {
            "id": "local-123",
            "title": "Local Product",
            "price": 49.99
        }
        """.data(using: .utf8)!

        let fileURL = URL(fileURLWithPath: "/tmp/mock.json")
        let urlResponse = URLResponse(
            url: fileURL,
            mimeType: "application/json",
            expectedContentLength: jsonData.count,
            textEncodingName: nil
        )

        // When
        let result: MockProduct = try sut.parse(request, data: jsonData, urlResponse: urlResponse)

        // Then
        XCTAssertEqual(result.id, "local-123", "correctly decodes local file")
        XCTAssertEqual(result.title, "Local Product", "correctly decodes title")
    }

    func test_parse_whenLocalFileWithInvalidJSON_shouldThrowError() {
        // Given
        let request = MockDecodableRequest()
        let invalidData = "invalid".data(using: .utf8)!

        let fileURL = URL(fileURLWithPath: "/tmp/mock.json")
        let urlResponse = URLResponse(
            url: fileURL,
            mimeType: "application/json",
            expectedContentLength: invalidData.count,
            textEncodingName: nil
        )

        // When / Then
        XCTAssertThrowsError(try sut.parse(request, data: invalidData, urlResponse: urlResponse)) { error in
            if case APIError.decodingFailed = error {
                // OK
            } else {
                XCTFail("should throw APIError.decodingFailed")
            }
        }
    }

    // MARK: - Invalid Response Tests

    func test_parse_whenNotHTTPResponse_shouldThrowInvalidResponse() {
        // Given
        let request = MockDecodableRequest()
        let data = Data()
        let urlResponse = URLResponse(
            url: URL(string: "https://api.example.com")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )

        // When / Then
        XCTAssertThrowsError(try sut.parse(request, data: data, urlResponse: urlResponse)) { error in
            if case APIError.invalidResponse = error {
                // OK
            } else {
                XCTFail("should throw APIError.invalidResponse")
            }
        }
    }

    // MARK: - Edge Cases

    func test_parse_whenEmptyData_shouldThrowDecodingError() {
        // Given
        let request = MockDecodableRequest()
        let emptyData = Data()

        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        // When / Then
        XCTAssertThrowsError(try sut.parse(request, data: emptyData, urlResponse: httpResponse)) { error in
            if case APIError.decodingFailed = error {
                // OK
            } else {
                XCTFail("should throw APIError.decodingFailed for empty data")
            }
        }
    }

    func test_parse_whenLargeJSON_shouldDecodeSuccessfully() throws {
        // Given
        let request = MockArrayRequest()
        var items: [[String: Any]] = []
        for i in 0..<1000 {
            items.append([
                "id": "\(i)",
                "title": "Product \(i)",
                "price": Double(i) * 10.0
            ])
        }

        let largeJSON = try JSONSerialization.data(withJSONObject: items)

        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        // When
        let result: [MockProduct] = try sut.parse(request, data: largeJSON, urlResponse: httpResponse)

        // Then
        XCTAssertEqual(result.count, 1000, "correctly decodes 1000 items")
    }

    func test_parse_whenSpecialCharactersInJSON_shouldDecodeCorrectly() throws {
        // Given
        let request = MockDecodableRequest()
        let specialCharsData = """
        {
            "id": "123",
            "title": "iPhone 15 Pro ™ 🎉",
            "price": 999.99
        }
        """.data(using: .utf8)!

        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        // When
        let result: MockProduct = try sut.parse(request, data: specialCharsData, urlResponse: httpResponse)

        // Then
        XCTAssertTrue(result.title.contains("™"), "preserves special characters")
        XCTAssertTrue(result.title.contains("🎉"), "preserves emojis")
    }
}
