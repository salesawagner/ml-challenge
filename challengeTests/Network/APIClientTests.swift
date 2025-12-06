//
//  APIClientTests.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class APIClientTests: XCTestCase {

    // MARK: - Properties

    var sut: APIClient!
    var mockEnvironment: Environment!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()

        mockEnvironment = EnvironmentFactory.createEnvironment(for: .local)
        sut = APIClient(environment: mockEnvironment)
    }

    override func tearDown() {
        sut = nil
        mockEnvironment = nil
        super.tearDown()
    }

    // MARK: - Successful Request Tests

    func test_send_whenSuccessful_shouldReturnDecodedResponse() async throws {
        // Given
        let request = ItemDescriptionRequest.dummy

        // When
        let result: ItemDescriptionRequest.Response = try await sut.send(request)

        // Then
        XCTAssertEqual(result.plainText, ItemDescriptionResponse.expected)
    }

    func test_send_whenMultipleRequests_shouldHandleIndependently() async throws {
        // Given
        let request1 = ItemDescriptionRequest.dummy
        let request2 = SearchRequest.dummy

        let result1: ItemDescriptionRequest.Response = try await sut.send(request1)
        let result2: SearchRequest.Response = try await sut.send(request2)

        // Then
        XCTAssertEqual(result1.plainText, ItemDescriptionResponse.expected, )
        XCTAssertEqual(result2.sellerID, SearchResponse.expected)
    }
}
