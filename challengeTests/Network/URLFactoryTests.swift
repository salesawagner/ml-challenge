//
//  URLFactoryTests.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class URLFactoryTests: XCTestCase {

    // MARK: - Properties

    var sut: URLFactory!
    var mockEnvironment: Environment!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = URLFactory()
        mockEnvironment = EnvironmentFactory.createEnvironment(for: .production)
    }

    override func tearDown() {
        sut = nil
        mockEnvironment = nil
        super.tearDown()
    }

    // MARK: - buildURL with Production Environment Tests

    func test_buildURL_whenProductionEnvironment_shouldReturnValidURL() throws {
        // Given
        mockEnvironment.domainURL = URL(string: "https://api.example.com")
        mockEnvironment.type = .production

        let request = MockAPIRequestWithJSON(resourceName: "items")

        // When
        let url = try sut.buildURL(for: request, environment: mockEnvironment)

        // Then
        XCTAssertNotNil(url, "must return valid URL")
        XCTAssertEqual(url?.absoluteString, "https://api.example.com/items", "must build correct URL")
    }

    func test_buildURL_whenProductionWithPath_shouldAppendPath() throws {
        // Given
        mockEnvironment.domainURL = URL(string: "https://api.example.com")
        mockEnvironment.type = .production

        let request = MockAPIRequestWithJSON(resourceName: "users/123/items")

        // When
        let url = try sut.buildURL(for: request, environment: mockEnvironment)

        // Then
        XCTAssertEqual(url?.absoluteString, "https://api.example.com/users/123/items", "must build URL with full path")
    }

    func test_buildURL_whenInvalidDomain_shouldThrowError() {
        // Given
        mockEnvironment.domainURL = nil
        mockEnvironment.type = .production

        let request = MockAPIRequest(resourceName: "items")

        // When / Then
        XCTAssertThrowsError(try sut.buildURL(for: request, environment: mockEnvironment)) { error in
            if case APIError.badUrl = error {
                // OK
            } else {
                XCTFail("must throw APIError.badUrl, but threw: \(error)")
            }
        }
    }

    // MARK: - buildURL with Local Environment Tests

    func test_buildURL_whenLocalEnvironment_shouldReturnLocalURL() throws {
        // Given
        mockEnvironment.type = .local

        /// mock(.json) file must be present in the Xcode project bundle
        let request = ItemsRequest(itemsId: [])

        // When
        let url = try sut.buildURL(for: request, environment: mockEnvironment)

        // Then
        XCTAssertNotNil(url, "must return local URL")
        XCTAssertTrue(url?.isFileURL == true, "must be file URL")
    }

    func test_buildURL_whenLocalEnvironmentWithoutLocalURL_shouldThrowError() {
        // Given
        mockEnvironment.type = .local

        let request = MockAPIRequest(resourceName: "items")

        // When / Then
        XCTAssertThrowsError(try sut.buildURL(for: request, environment: mockEnvironment)) { error in
            if case APIError.badUrl = error {
                // OK
            } else {
                XCTFail("must throw APIError.badUrl")
            }
        }
    }

    // MARK: - Query Parameters Tests

    func test_buildURL_whenQuerySerialization_shouldAddQueryParameters() throws {
        // Given
        mockEnvironment.domainURL = URL(string: "https://api.example.com")
        mockEnvironment.type = .production

        let request = MockAPIRequestWithQuery(
            resourceName: "search",
            query: "laptop",
            limit: 20
        )

        // When
        let url = try sut.buildURL(for: request, environment: mockEnvironment)

        // Then
        XCTAssertNotNil(url, "must return URL")
        let urlString = url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("query=laptop"), "must contain query parameter")
        XCTAssertTrue(urlString.contains("limit=20"), "must contain limit parameter")
    }

    func test_buildURL_whenJSONSerialization_shouldNotAddQueryParameters() throws {
        // Given
        mockEnvironment.domainURL = URL(string: "https://api.example.com")
        mockEnvironment.type = .production

        let request = MockAPIRequestWithJSON(resourceName: "items")

        // When
        let url = try sut.buildURL(for: request, environment: mockEnvironment)

        // Then
        XCTAssertNotNil(url, "must return URL")
        XCTAssertFalse(url?.absoluteString.contains("?") ?? false, "must not contain query string")
    }

    func test_buildURL_whenFormURLEncodedSerialization_shouldNotAddQueryParameters() throws {
        // Given
        mockEnvironment.domainURL = URL(string: "https://api.example.com")
        mockEnvironment.type = .production

        let request = MockAPIRequestWithFormURLEncoded(resourceName: "oauth/token")

        // When
        let url = try sut.buildURL(for: request, environment: mockEnvironment)

        // Then
        XCTAssertNotNil(url, "must return URL")
        XCTAssertFalse(url?.absoluteString.contains("?") ?? false, "must not contain query string")
    }

    // MARK: - Special Characters Tests

    func test_buildURL_whenResourceWithSpecialCharacters_shouldHandleCorrectly() throws {
        // Given
        mockEnvironment.domainURL = URL(string: "https://api.example.com")
        mockEnvironment.type = .production

        let request = MockAPIRequest(resourceName: "items/MLB-123")

        // When
        let url = try sut.buildURL(for: request, environment: mockEnvironment)

        // Then
        XCTAssertNotNil(url, "must return valid URL")
        XCTAssertTrue(url?.absoluteString.contains("MLB-123") ?? false, "must preserve special characters")
    }

    func test_buildURL_whenQueryWithSpecialCharacters_shouldEncodeCorrectly() throws {
        // Given
        mockEnvironment.domainURL = URL(string: "https://api.example.com")
        mockEnvironment.type = .production

        let request = MockAPIRequestWithQuery(
            resourceName: "search",
            query: "iPhone 15 Pro",
            limit: 10
        )

        // When
        let url = try sut.buildURL(for: request, environment: mockEnvironment)

        // Then
        XCTAssertNotNil(url, "must return URL")
        let urlString = url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("query=iPhone"), "must encode spaces correctly")
    }

    // MARK: - Edge Cases

    func test_buildURL_whenResourceNameWithLeadingSlash_shouldHandleCorrectly() throws {
        // Given
        mockEnvironment.domainURL = URL(string: "https://api.example.com")
        mockEnvironment.type = .production

        let request = MockAPIRequest(resourceName: "/items")

        // When
        let url = try sut.buildURL(for: request, environment: mockEnvironment)

        // Then
        XCTAssertNotNil(url, "must return valid URL")
    }

    func test_buildURL_whenMultipleQueryParameters_shouldIncludeAll() throws {
        // Given
        mockEnvironment.domainURL = URL(string: "https://api.example.com")
        mockEnvironment.type = .production

        let request = MockAPIRequestWithMultipleQuery(
            resourceName: "search",
            query: "laptop",
            limit: 20,
            offset: 0,
            sort: "price_asc"
        )

        // When
        let url = try sut.buildURL(for: request, environment: mockEnvironment)

        // Then
        XCTAssertNotNil(url, "must return URL")
        let urlString = url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("query=laptop"), "must contain query")
        XCTAssertTrue(urlString.contains("limit=20"), "must contain limit")
        XCTAssertTrue(urlString.contains("offset=0"), "must contain offset")
        XCTAssertTrue(urlString.contains("sort=price_asc"), "must contain sort")
    }
}
