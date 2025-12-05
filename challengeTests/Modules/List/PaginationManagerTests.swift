//
//  PaginationManagerTests.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import XCTest
@testable import challenge

final class PaginationManagerTests: XCTestCase {

    var sut: ListPaginationManager!

    override func setUp() {
        super.setUp()
        sut = ListPaginationManager(offset: 0, limit: 20)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_shouldSetInitialValues() {
        // Given/When (initialized in setUp)

        // Then
        XCTAssertEqual(sut.offset, 0)
        XCTAssertEqual(sut.limit, 20)
        XCTAssertEqual(sut.total, 0)
    }

    func test_canLoadMore_withoutTotal_shouldReturnTrue() {
        // Given (no total set)

        // When
        let canLoad = sut.canLoadMore

        // Then
        XCTAssertTrue(canLoad)
    }

    // MARK: - Update Total Tests

    func test_updateTotal_shouldSetTotal() {
        // Given
        let expectedTotal = 100

        // When
        sut.updateTotal(expectedTotal)

        // Then
        XCTAssertEqual(sut.total, expectedTotal)
    }

    func test_canLoadMore_whenHasMoreItems_shouldReturnTrue() {
        // Given
        sut.updateTotal(100)

        // When
        let canLoad = sut.canLoadMore

        // Then
        XCTAssertTrue(canLoad)
    }

    func test_canLoadMore_whenNoMoreItems_shouldReturnFalse() {
        // Given
        sut.updateTotal(10)
        sut.nextPage() // offset = 20, total = 10

        // When
        let canLoad = sut.canLoadMore

        // Then
        XCTAssertFalse(canLoad)
    }

    // MARK: - Next Page Tests

    func test_nextPage_shouldIncrementOffset() {
        // Given
        sut.updateTotal(100)
        let initialOffset = sut.offset

        // When
        sut.nextPage()

        // Then
        XCTAssertEqual(sut.offset, initialOffset + sut.limit)
    }

    func test_nextPage_whenCannotLoadMore_shouldNotIncrementOffset() {
        // Given
        sut.updateTotal(10)
        sut.nextPage() // offset = 20, can't load more
        let offsetBeforeCall = sut.offset

        // When
        sut.nextPage()

        // Then
        XCTAssertEqual(sut.offset, offsetBeforeCall)
    }

    // MARK: - Reset Tests

    func test_reset_shouldRestoreInitialValues() {
        // Given
        sut.updateTotal(100)
        sut.nextPage()
        sut.nextPage()

        // When
        sut.reset()

        // Then
        XCTAssertEqual(sut.offset, 0)
        XCTAssertEqual(sut.limit, 20)
        XCTAssertEqual(sut.total, 0)
    }

    // MARK: - PaginationInfo Tests

    func test_info_shouldReturnCorrectValues() {
        // Given
        sut.updateTotal(100)
        sut.nextPage()

        // When
        let info = sut.info

        // Then
        XCTAssertEqual(info.offset, 20)
        XCTAssertEqual(info.limit, 20)
        XCTAssertEqual(info.total, 100)
        XCTAssertTrue(info.canLoadMore)
    }
}
