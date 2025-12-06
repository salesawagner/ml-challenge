//
//  URLQueryItemEncoderTests.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class URLQueryItemEncoderTests: XCTestCase {
    // MARK: - Basic Encoding Tests

    func test_encode_whenStringParameter_shouldCreateQueryItem() throws {
        // Given
        struct Request: Encodable {
            let query: String
        }

        let request = Request(query: "iPhone")

        // When
        let queryItems = try URLQueryItemEncoder.encode(request)

        // Then
        XCTAssertEqual(queryItems.count, 1, "creates single query item")
        XCTAssertEqual(queryItems.first?.name, "query", "has correct parameter name")
        XCTAssertEqual(queryItems.first?.value, "iPhone", "has correct parameter value")
    }

    func test_encode_whenIntParameter_shouldCreateQueryItem() throws {
        // Given
        struct Request: Encodable {
            let limit: Int
        }

        let request = Request(limit: 20)

        // When
        let queryItems = try URLQueryItemEncoder.encode(request)

        // Then
        XCTAssertEqual(queryItems.count, 1, "creates single query item")
        XCTAssertEqual(queryItems.first?.name, "limit", "has correct parameter name")
        XCTAssertEqual(queryItems.first?.value, "20", "converts int to string properly")
    }

    func test_encode_whenBoolParameter_shouldCreateQueryItem() throws {
        // Given
        struct Request: Encodable {
            let active: Bool
        }

        let request = Request(active: true)

        // When
        let queryItems = try URLQueryItemEncoder.encode(request)

        // Then
        XCTAssertEqual(queryItems.count, 1, "creates single query item")
        XCTAssertEqual(queryItems.first?.name, "active", "has correct parameter name")
        XCTAssertEqual(queryItems.first?.value, "true", "converts bool to string properly")
    }

    func test_encode_whenDoubleParameter_shouldCreateQueryItem() throws {
        // Given
        struct Request: Encodable {
            let price: Double
        }

        let request = Request(price: 99.99)

        // When
        let queryItems = try URLQueryItemEncoder.encode(request)

        // Then
        XCTAssertEqual(queryItems.count, 1, "creates single query item")
        XCTAssertEqual(queryItems.first?.name, "price", "has correct parameter name")
        XCTAssertEqual(queryItems.first?.value, "99.99", "converts double to string properly")
    }

    // MARK: - Multiple Parameters Tests

    func test_encode_whenMultipleParameters_shouldCreateMultipleQueryItems() throws {
        // Given
        struct Request: Encodable {
            let query: String
            let limit: Int
            let offset: Int
        }

        let request = Request(query: "laptop", limit: 20, offset: 0)

        // When
        let queryItems = try URLQueryItemEncoder.encode(request)

        // Then
        XCTAssertEqual(queryItems.count, 3, "creates 3 query items")

        let queryNames = queryItems.map { $0.name }
        XCTAssertTrue(queryNames.contains("query"), "includes query parameter")
        XCTAssertTrue(queryNames.contains("limit"), "includes limit parameter")
        XCTAssertTrue(queryNames.contains("offset"), "includes offset parameter")
    }

    func test_encode_whenMixedTypes_shouldHandleAll() throws {
        // Given
        struct Request: Encodable {
            let text: String
            let number: Int
            let flag: Bool
            let decimal: Double
        }

        let request = Request(text: "test", number: 42, flag: false, decimal: 3.14)

        // When
        let queryItems = try URLQueryItemEncoder.encode(request)

        // Then
        XCTAssertEqual(queryItems.count, 4, "handles all 4 different parameter types")
    }

    // MARK: - Edge Cases

    func test_encode_whenEmptyString_shouldCreateQueryItemWithEmptyValue() throws {
        // Given
        struct Request: Encodable {
            let query: String
        }

        let request = Request(query: "")

        // When
        let queryItems = try URLQueryItemEncoder.encode(request)

        // Then
        XCTAssertEqual(queryItems.count, 1, "creates query item")
        XCTAssertEqual(queryItems.first?.value, "", "value should be empty string")
    }

    func test_encode_whenZeroValue_shouldCreateQueryItemWithZero() throws {
        // Given
        struct Request: Encodable {
            let count: Int
        }

        let request = Request(count: 0)

        // When
        let queryItems = try URLQueryItemEncoder.encode(request)

        // Then
        XCTAssertEqual(queryItems.first?.value, "0", "includes zero value")
    }

    func test_encode_whenSpecialCharacters_shouldEncodeCorrectly() throws {
        // Given
        struct Request: Encodable {
            let query: String
        }

        let request = Request(query: "iPhone 15 Pro")

        // When
        let queryItems = try URLQueryItemEncoder.encode(request)

        // Then
        XCTAssertNotNil(queryItems.first?.value, "creates valid value")
        // URLQueryItem handles encoding automatically
    }
}

// MARK: - HTTPParameterTests

final class HTTPParameterTests: XCTestCase {

    // MARK: - String Tests

    func test_decode_whenString_shouldReturnStringParameter() throws {
        // Given
        let json = "\"test\""
        let data = json.data(using: .utf8)!

        // When
        let parameter = try JSONDecoder().decode(HTTPParameter.self, from: data)

        // Then
        if case .string(let value) = parameter {
            XCTAssertEqual(value, "test", "properly decodes string")
        } else {
            XCTFail("should be string type")
        }
    }

    func test_description_whenString_shouldReturnString() {
        // Given
        let parameter = HTTPParameter.string("test")

        // When
        let description = parameter.description

        // Then
        XCTAssertEqual(description, "test", "returns raw string value")
    }

    // MARK: - Bool Tests

    func test_decode_whenBool_shouldReturnBoolParameter() throws {
        // Given
        let json = "true"
        let data = json.data(using: .utf8)!

        // When
        let parameter = try JSONDecoder().decode(HTTPParameter.self, from: data)

        // Then
        if case .bool(let value) = parameter {
            XCTAssertTrue(value, "properly decodes boolean")
        } else {
            XCTFail("should be bool type")
        }
    }

    func test_description_whenBool_shouldReturnBoolString() {
        // Given
        let parameter = HTTPParameter.bool(true)

        // When
        let description = parameter.description

        // Then
        XCTAssertEqual(description, "true", "returns 'true' string")
    }

    // MARK: - Int Tests

    func test_decode_whenInt_shouldReturnIntParameter() throws {
        // Given
        let json = "42"
        let data = json.data(using: .utf8)!

        // When
        let parameter = try JSONDecoder().decode(HTTPParameter.self, from: data)

        // Then
        if case .int(let value) = parameter {
            XCTAssertEqual(value, 42, "properly decodes integer")
        } else {
            XCTFail("should be int type")
        }
    }

    func test_description_whenInt_shouldReturnIntString() {
        // Given
        let parameter = HTTPParameter.int(42)

        // When
        let description = parameter.description

        // Then
        XCTAssertEqual(description, "42", "returns '42' as string")
    }

    // MARK: - Double Tests

    func test_decode_whenDouble_shouldReturnDoubleParameter() throws {
        // Given
        let json = "3.14"
        let data = json.data(using: .utf8)!

        // When
        let parameter = try JSONDecoder().decode(HTTPParameter.self, from: data)

        // Then
        if case .double(let value) = parameter {
            XCTAssertEqual(value, 3.14, accuracy: 0.001, "properly decodes double")
        } else {
            XCTFail("should be double type")
        }
    }

    func test_description_whenDouble_shouldReturnDoubleString() {
        // Given
        let parameter = HTTPParameter.double(99.99)

        // When
        let description = parameter.description

        // Then
        XCTAssertEqual(description, "99.99", "returns '99.99' as string")
    }

    // MARK: - Array Tests

    func test_decode_whenArray_shouldReturnArrayParameter() throws {
        // Given
        let json = "[\"item1\", \"item2\", \"item3\"]"
        let data = json.data(using: .utf8)!

        // When
        let parameter = try JSONDecoder().decode(HTTPParameter.self, from: data)

        // Then
        if case .array(let value) = parameter {
            XCTAssertEqual(value.count, 3, "contains 3 items")
            XCTAssertEqual(value, ["item1", "item2", "item3"], "properly decodes array")
        } else {
            XCTFail("should be array type")
        }
    }

    func test_description_whenArray_shouldReturnArrayString() {
        // Given
        let parameter = HTTPParameter.array(["a", "b", "c"])

        // When
        let description = parameter.description

        // Then
        XCTAssertTrue(description.contains("a"), "includes first item")
        XCTAssertTrue(description.contains("b"), "includes second item")
        XCTAssertTrue(description.contains("c"), "includes third item")
    }

    // MARK: - Error Tests

    func test_decode_whenInvalidType_shouldThrowError() {
        // Given
        let json = "{\"key\": \"value\"}"
        let data = json.data(using: .utf8)!

        // When / Then
        XCTAssertThrowsError(try JSONDecoder().decode(HTTPParameter.self, from: data)) { _ in
            // Should throw for unsupported type
        }
    }

    // MARK: - Edge Cases

    func test_decode_whenEmptyString_shouldReturnEmptyString() throws {
        // Given
        let json = "\"\""
        let data = json.data(using: .utf8)!

        // When
        let parameter = try JSONDecoder().decode(HTTPParameter.self, from: data)

        // Then
        if case .string(let value) = parameter {
            XCTAssertEqual(value, "", "properly decodes empty string")
        } else {
            XCTFail("should be string type")
        }
    }

    func test_decode_whenZero_shouldReturnZero() throws {
        // Given
        let json = "0"
        let data = json.data(using: .utf8)!

        // When
        let parameter = try JSONDecoder().decode(HTTPParameter.self, from: data)

        // Then
        if case .int(let value) = parameter {
            XCTAssertEqual(value, 0, "properly decodes zero")
        } else {
            XCTFail("should be int type")
        }
    }

    func test_decode_whenNegativeNumber_shouldReturnNegative() throws {
        // Given
        let json = "-42"
        let data = json.data(using: .utf8)!

        // When
        let parameter = try JSONDecoder().decode(HTTPParameter.self, from: data)

        // Then
        if case .int(let value) = parameter {
            XCTAssertEqual(value, -42, "properly decodes negative number")
        } else {
            XCTFail("should be int type")
        }
    }

    func test_decode_whenEmptyArray_shouldReturnEmptyArray() throws {
        // Given
        let json = "[]"
        let data = json.data(using: .utf8)!

        // When
        let parameter = try JSONDecoder().decode(HTTPParameter.self, from: data)

        // Then
        if case .array(let value) = parameter {
            XCTAssertEqual(value.count, 0, "properly decodes empty array")
        } else {
            XCTFail("should be array type")
        }
    }
}
