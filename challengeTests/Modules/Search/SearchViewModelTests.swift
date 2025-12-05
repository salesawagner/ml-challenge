//
//  SearchViewModelTests.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class SearchViewModelTests: XCTestCase {
    // MARK: - Properties

    var sut: SearchViewModel!
    let testUserId = 123

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
        XCTAssertEqual(sut.userId, testUserId, "deve definir userId corretamente")
        XCTAssertNil(sut.searchQuery, "searchQuery deve ser nil inicialmente")
        XCTAssertFalse(sut.isSearchValid, "isSearchValid deve ser false inicialmente")
    }

    // MARK: - searchQuery Tests

    func test_searchQuery_whenSet_shouldTriggerValidation() {
        // Given
        var validationCalled = false
        sut.didUpdateValidation = { _ in
            validationCalled = true
        }

        // When
        sut.searchQuery = "test"

        // Then
        XCTAssertTrue(validationCalled, "deve chamar callback de validação")
    }

    func test_searchQuery_whenSetToNil_shouldInvalidate() {
        // Given
        sut.searchQuery = "valid query"

        // When
        sut.searchQuery = nil

        // Then
        XCTAssertFalse(sut.isSearchValid, "deve invalidar quando query é nil")
    }

    // MARK: - validateSearch Tests

    func test_validateSearch_whenQueryIsNil_shouldBeInvalid() {
        // Given
        sut.searchQuery = nil

        // When
        sut.validateSearch()

        // Then
        XCTAssertFalse(sut.isSearchValid, "deve ser inválido quando query é nil")
    }

    func test_validateSearch_whenQueryIsEmpty_shouldBeInvalid() {
        // Given
        sut.searchQuery = ""

        // When
        sut.validateSearch()

        // Then
        XCTAssertFalse(sut.isSearchValid, "deve ser inválido quando query é vazio")
    }

    func test_validateSearch_whenQueryHasOnlyWhitespace_shouldBeInvalid() {
        // Given
        sut.searchQuery = "   "

        // When
        sut.validateSearch()

        // Then
        XCTAssertFalse(sut.isSearchValid, "deve ser inválido quando query tem apenas espaços")
    }

    func test_validateSearch_whenQueryHasLessThan3Characters_shouldBeInvalid() {
        // Given
        sut.searchQuery = "ab"

        // When
        sut.validateSearch()

        // Then
        XCTAssertFalse(sut.isSearchValid, "deve ser inválido quando query tem menos de 3 caracteres")
    }

    func test_validateSearch_whenQueryHasExactly3Characters_shouldBeValid() {
        // Given
        sut.searchQuery = "abc"

        // When
        sut.validateSearch()

        // Then
        XCTAssertTrue(sut.isSearchValid, "deve ser válido quando query tem exatamente 3 caracteres")
    }

    func test_validateSearch_whenQueryHasMoreThan3Characters_shouldBeValid() {
        // Given
        sut.searchQuery = "laptop"

        // When
        sut.validateSearch()

        // Then
        XCTAssertTrue(sut.isSearchValid, "deve ser válido quando query tem mais de 3 caracteres")
    }

    func test_validateSearch_whenQueryHasWhitespaceAround_shouldTrimAndValidate() {
        // Given
        sut.searchQuery = "  test  "

        // When
        sut.validateSearch()

        // Then
        XCTAssertTrue(sut.isSearchValid, "deve fazer trim e validar corretamente")
    }

    // MARK: - isSearchValid Tests

    func test_isSearchValid_whenChanges_shouldNotifyCallback() {
        // Given
        var callbackCount = 0
        var receivedValue: Bool?
        sut.didUpdateValidation = { isValid in
            callbackCount += 1
            receivedValue = isValid
        }

        // When
        sut.searchQuery = "laptop"

        // Then
        XCTAssertEqual(callbackCount, 1, "callback deve ser chamado uma vez")
        XCTAssertEqual(receivedValue, true, "callback deve receber valor correto")
    }

    func test_isSearchValid_whenNoCallback_shouldNotCrash() {
        // Given
        sut.didUpdateValidation = nil

        // When / Then
        sut.searchQuery = "test" // não deve crashear
        XCTAssertTrue(sut.isSearchValid, "deve validar mesmo sem callback")
    }

    // MARK: - performSearch Tests

    func test_performSearch_whenQueryIsValid_shouldReturnTrimmedQuery() {
        // Given
        sut.searchQuery = "  laptop  "

        // When
        let result = sut.performSearch()

        // Then
        XCTAssertEqual(result, "laptop", "deve retornar query com trim")
    }

    func test_performSearch_whenQueryIsInvalid_shouldReturnNil() {
        // Given
        sut.searchQuery = "ab"

        // When
        let result = sut.performSearch()

        // Then
        XCTAssertNil(result, "deve retornar nil quando query é inválido")
    }

    func test_performSearch_whenQueryIsNil_shouldReturnNil() {
        // Given
        sut.searchQuery = nil

        // When
        let result = sut.performSearch()

        // Then
        XCTAssertNil(result, "deve retornar nil quando query é nil")
    }

    func test_performSearch_whenQueryIsEmpty_shouldReturnNil() {
        // Given
        sut.searchQuery = ""

        // When
        let result = sut.performSearch()

        // Then
        XCTAssertNil(result, "deve retornar nil quando query é vazio")
    }

    // MARK: - Edge Cases

    func test_searchQuery_whenSetMultipleTimes_shouldValidateEachTime() {
        // Given
        var callbackCount = 0
        sut.didUpdateValidation = { _ in
            callbackCount += 1
        }

        // When
        sut.searchQuery = "ab"
        sut.searchQuery = "abc"
        sut.searchQuery = "laptop"

        // Then
        XCTAssertEqual(callbackCount, 3, "callback deve ser chamado para cada mudança")
    }

    func test_validateSearch_whenQueryHasSpecialCharacters_shouldValidateLength() {
        // Given
        sut.searchQuery = "!@#"

        // When
        sut.validateSearch()

        // Then
        XCTAssertTrue(sut.isSearchValid, "deve validar apenas o tamanho, não o conteúdo")
    }

    func test_validateSearch_whenQueryHasNumbers_shouldBeValid() {
        // Given
        sut.searchQuery = "123"

        // When
        sut.validateSearch()

        // Then
        XCTAssertTrue(sut.isSearchValid, "deve aceitar números")
    }

    func test_validateSearch_whenQueryHasUnicode_shouldBeValid() {
        // Given
        sut.searchQuery = "café"

        // When
        sut.validateSearch()

        // Then
        XCTAssertTrue(sut.isSearchValid, "deve aceitar caracteres unicode")
    }

    // MARK: - Helpers

    private func makeSut() -> SearchViewModel {
        SearchViewModel(userId: testUserId)
    }
}
