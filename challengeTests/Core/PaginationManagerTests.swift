//
//  PaginationManagerTests.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class PaginationManagerTests: XCTestCase {
    // MARK: - Properties

    var sut: PaginationManager!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = makeSut()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_whenCreated_shouldSetDefaultValues() {
        // Given / When (no setUp)

        // Then
        XCTAssertEqual(sut.offset, 0, "offset inicial deve ser 0")
        XCTAssertEqual(sut.limit, 20, "limit inicial deve ser 20")
        XCTAssertEqual(sut.total, 0, "total inicial deve ser 0")
        XCTAssertTrue(sut.canLoadMore, "deve permitir carregar mais inicialmente")
    }

    func test_init_whenCustomValues_shouldSetCorrectValues() {
        // Given
        let customOffset = 10
        let customLimit = 30

        // When
        sut = PaginationManager(offset: customOffset, limit: customLimit)

        // Then
        XCTAssertEqual(sut.offset, customOffset, "deve usar offset customizado")
        XCTAssertEqual(sut.limit, customLimit, "deve usar limit customizado")
    }

    // MARK: - updateTotal Tests

    func test_updateTotal_whenCalled_shouldUpdateTotalValue() {
        // Given
        let newTotal = 100

        // When
        sut.updateTotal(newTotal)

        // Then
        XCTAssertEqual(sut.total, newTotal, "deve atualizar total corretamente")
    }

    // MARK: - nextPage Tests

    func test_nextPage_whenCanLoadMore_shouldIncreaseOffset() {
        // Given
        sut.updateTotal(100)
        let initialOffset = sut.offset

        // When
        sut.nextPage()

        // Then
        XCTAssertEqual(sut.offset, initialOffset + sut.limit, "offset deve avançar pelo limit")
    }

    func test_nextPage_whenCannotLoadMore_shouldNotChangeOffset() {
        // Given
        sut.updateTotal(10)
        sut.nextPage() // offset = 20, total = 10
        let offsetBeforeCall = sut.offset

        // When
        sut.nextPage()

        // Then
        XCTAssertEqual(sut.offset, offsetBeforeCall, "offset não deve mudar quando não pode carregar mais")
    }

    // MARK: - canLoadMore Tests

    func test_canLoadMore_whenOffsetLessThanTotal_shouldReturnTrue() {
        // Given
        sut.updateTotal(100)

        // When
        let result = sut.canLoadMore

        // Then
        XCTAssertTrue(result, "deve permitir carregar mais quando offset < total")
    }

    func test_canLoadMore_whenOffsetEqualsTotal_shouldReturnFalse() {
        // Given
        sut.updateTotal(20)
        sut.nextPage() // offset = 20

        // When
        let result = sut.canLoadMore

        // Then
        XCTAssertFalse(result, "não deve permitir carregar mais quando offset >= total")
    }

    func test_canLoadMore_whenTotalIsZero_shouldReturnTrue() {
        // Given
        sut.updateTotal(0)

        // When
        let result = sut.canLoadMore

        // Then
        XCTAssertTrue(result, "deve permitir carregar mais quando total é zero (primeira carga)")
    }

    // MARK: - reset Tests

    func test_reset_whenCalled_shouldResetToInitialValues() {
        // Given
        sut.updateTotal(100)
        sut.nextPage()
        sut.nextPage()

        // When
        sut.reset()

        // Then
        XCTAssertEqual(sut.offset, 0, "offset deve voltar ao valor inicial")
        XCTAssertEqual(sut.limit, 20, "limit deve voltar ao valor inicial")
        XCTAssertEqual(sut.total, 0, "total deve ser zerado")
        XCTAssertTrue(sut.canLoadMore, "deve permitir carregar mais após reset")
    }

    func test_reset_whenCustomInitialValues_shouldResetToCustomValues() {
        // Given
        sut = PaginationManager(offset: 10, limit: 30)
        sut.updateTotal(100)
        sut.nextPage()

        // When
        sut.reset()

        // Then
        XCTAssertEqual(sut.offset, 10, "deve resetar para offset inicial customizado")
        XCTAssertEqual(sut.limit, 30, "deve resetar para limit inicial customizado")
    }

    // MARK: - info Tests

    func test_info_whenCalled_shouldReturnCorrectPaginationInfo() {
        // Given
        sut.updateTotal(100)

        // When
        let info = sut.info

        // Then
        XCTAssertEqual(info.offset, sut.offset, "info deve ter offset correto")
        XCTAssertEqual(info.limit, sut.limit, "info deve ter limit correto")
        XCTAssertEqual(info.total, sut.total, "info deve ter total correto")
        XCTAssertEqual(info.canLoadMore, sut.canLoadMore, "info deve ter canLoadMore correto")
    }

    // MARK: - Edge Cases

    func test_nextPage_whenMultipleCalls_shouldIncrementCorrectly() {
        // Given
        sut.updateTotal(100)

        // When
        sut.nextPage() // offset = 20
        sut.nextPage() // offset = 40
        sut.nextPage() // offset = 60

        // Then
        XCTAssertEqual(sut.offset, 60, "offset deve incrementar corretamente em múltiplas chamadas")
        XCTAssertTrue(sut.canLoadMore, "deve ainda poder carregar mais")
    }

    func test_canLoadMore_whenOffsetGreaterThanTotal_shouldReturnFalse() {
        // Given
        sut.updateTotal(5)
        sut.nextPage() // offset = 20, total = 5

        // When
        let result = sut.canLoadMore

        // Then
        XCTAssertFalse(result, "não deve permitir carregar quando offset > total")
    }

    // MARK: - Helpers

    private func makeSut() -> PaginationManager {
        PaginationManager()
    }
}
