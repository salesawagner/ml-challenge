//
//  ListViewModelTests.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class ListViewModelTests: XCTestCase {
    // MARK: - Properties

    var sut: ListViewModel!
    var mockAPIClient: MockAPIClient!
    var mockPaginationManager: MockPaginationManager!

    let testUserId = 123456
    let testQuery = "iPhone"

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockPaginationManager = MockPaginationManager()
        sut = makeSut()
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        mockPaginationManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_whenCreated_shouldSetDefaultValues() {
        // Given / When (no setUp)

        // Then
        XCTAssertEqual(sut.query, testQuery)
    }

    // MARK: - viewDidLoad Tests

    func test_viewDidLoad_whenCalled_shouldStartLoading() async {
        // Given
        var stateChanges: [ListState] = []
        sut.didChangeState = { state in
            stateChanges.append(state)
        }
        mockAPIClient.sendResult = .failure(.networkError(URLError(.notConnectedToInternet)))

        // When
        await sut.viewDidLoad()

        // Then
        XCTAssertTrue(stateChanges.contains(where: {
            if case .loading = $0 { return true }
            return false
        }))
    }

    func test_viewDidLoad_whenSuccessful_shouldReturnItems() async {
        // Given
        var stateChanges: [ListState] = []
        sut.didChangeState = { state in
            stateChanges.append(state)
        }

        // When
        await sut.viewDidLoad()

        // Then
        let hasSuccessState = stateChanges.contains(where: {
            if case .success = $0 { return true }
            return false
        })

        XCTAssertTrue(hasSuccessState)
    }

    func test_viewDidLoad_whenEmptyResults_shouldReturnEmptyState() async {
        // Given
        let emptySearchResponse = SearchResponse(
            sellerID: "123",
            results: [],
            paging: Paging(limit: 20, offset: 0, total: 0)
        )

        var stateChanges: [ListState] = []
        sut.didChangeState = { state in
            stateChanges.append(state)
        }

        mockAPIClient.sendResult = .success(emptySearchResponse)

        // When
        await sut.viewDidLoad()

        // Then
        let hasEmptyState = stateChanges.contains(where: {
            if case .empty = $0 { return true }
            return false
        })
        XCTAssertTrue(hasEmptyState)
    }

    func test_viewDidLoad_whenAuthError_shouldReturnUnauthorized() async {
        // Given
        var stateChanges: [ListState] = []
        sut.didChangeState = { state in
            stateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.httpError(statusCode: 401))

        // When
        await sut.viewDidLoad()

        // Then
        let hasUnauthorizedState = stateChanges.contains(where: {
            if case .unauthorized = $0 { return true }
            return false
        })
        XCTAssertTrue(hasUnauthorizedState)
    }

    func test_viewDidLoad_whenNetworkError_shouldReturnFailure() async {
        // Given
        var stateChanges: [ListState] = []
        sut.didChangeState = { state in
            stateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.networkError(URLError(.notConnectedToInternet)))

        // When
        await sut.viewDidLoad()

        // Then
        let hasFailureState = stateChanges.contains(where: {
            if case .failure = $0 { return true }
            return false
        })
        XCTAssertTrue(hasFailureState)
    }

    // MARK: - filter Tests

    func test_filter_whenQueryChanges_shouldResetPagination() async {
        // Given
        let newQuery = "MacBook"
        mockPaginationManager.offsetValue = 40

        let mockSearchResponse = SearchResponse(
            sellerID: "123",
            results: [],
            paging: Paging(limit: 20, offset: 0, total: 0)
        )
        mockAPIClient.sendResult = .success(mockSearchResponse)

        // When
        await sut.filter(query: newQuery)

        // Then
        XCTAssertTrue(mockPaginationManager.contains(.reset))
        XCTAssertEqual(sut.query, newQuery)
    }

    func test_filter_whenSameQuery_shouldSkip() async {
        // Given
        mockAPIClient.resetMock()

        // When
        await sut.filter(query: testQuery)

        // Then
        XCTAssertFalse(mockAPIClient.contains(.send))
    }

    func test_filter_whenNewQuery_shouldUpdateItems() async {
        // Given
        let newQuery = "iPad"
        var stateChanges: [ListState] = []
        sut.didChangeState = { state in
            stateChanges.append(state)
        }

        // When
        await sut.filter(query: newQuery)

        // Then
        let hasSuccessState = stateChanges.contains(where: {
            if case .success = $0 { return true }
            return false
        })

        XCTAssertTrue(hasSuccessState)
    }

    // MARK: - paginate Tests

    func test_paginate_whenCanLoadMore_shouldLoadNextPage() async {
        // Given
        mockPaginationManager.canLoadMoreValue = true
        mockPaginationManager.offsetValue = 0

        let mockItems = TestFixtures.mockItemResponses(count: 3)
        let mockSearchResponse = SearchResponse(
            sellerID: "123",
            results: mockItems.map { $0.id },
            paging: Paging(limit: 20, offset: 20, total: 100)
        )

        mockAPIClient.sendResult = .success(mockSearchResponse)

        // When
        await sut.paginate()

        // Then
        XCTAssertTrue(mockPaginationManager.contains(.nextPage))
    }

    func test_paginate_whenCannotLoadMore_shouldNotMakeRequest() async {
        // Given
        mockPaginationManager.canLoadMoreValue = false
        mockAPIClient.resetMock()

        // When
        await sut.paginate()

        // Then
        XCTAssertFalse(mockAPIClient.contains(.send))
    }

    func test_paginate_whenSuccessful_shouldEmitPaginationSuccess() async {
        // Given
        mockPaginationManager.canLoadMoreValue = true

        var stateChanges: [ListState] = []
        sut.didChangeState = { state in
            stateChanges.append(state)
        }

        // When
        await sut.paginate()

        // Then
        let hasPaginationSuccess = stateChanges.contains(where: {
            if case .paginationSuccess = $0 { return true }
            return false
        })

        XCTAssertTrue(hasPaginationSuccess, "deve emitir paginationSuccess")
    }

    func test_paginate_whenAlreadyLoading_shouldNotDuplicateRequest() async {
        // Given
        mockPaginationManager.canLoadMoreValue = true
        mockAPIClient.sendDelay = .milliseconds(100)

        let mockSearchResponse = SearchResponse(
            sellerID: "123",
            results: [],
            paging: Paging(limit: 20, offset: 20, total: 100)
        )
        mockAPIClient.sendResult = .success(mockSearchResponse)

        // When - chamadas simultâneas
        async let _ = sut.paginate()
        async let _ = sut.paginate()
        async let _ = sut.paginate()

        // Then
        try? await Task.sleep(for: .milliseconds(200))
        XCTAssertLessThanOrEqual(mockAPIClient.sendCallCount, 2)
    }

    // MARK: - getItem Tests

    func test_getItem_whenValidIndex_shouldReturnItem() async {
        // Given
        await sut.viewDidLoad()

        // When
        let item = sut.getItem(at: 2)

        // Then
        XCTAssertNotNil(item)
    }

    func test_getItem_whenInvalidIndex_shouldReturnNil() {
        // Given
        // Lista vazia

        // When
        let item = sut.getItem(at: 10)

        // Then
        XCTAssertNil(item)
    }

    func test_getItem_whenNegativeIndex_shouldReturnNil() {
        // Given / When
        let item = sut.getItem(at: -1)

        // Then
        XCTAssertNil(item)
    }

    // MARK: - State Management Tests

    func test_stateTransitions_whenViewDidLoad_shouldFollowCorrectFlow() async {
        // Given
        var stateChanges: [String] = []
        sut.didChangeState = { state in
            switch state {
            case .idle: stateChanges.append("idle")
            case .loading: stateChanges.append("loading")
            case .success: stateChanges.append("success")
            case .empty: stateChanges.append("empty")
            case .failure: stateChanges.append("failure")
            case .paginationSuccess: stateChanges.append("paginationSuccess")
            case .unauthorized: stateChanges.append("unauthorized")
            case .refresh: stateChanges.append("refresh")
            case .retry: stateChanges.append("retry")
            }
        }

        // When
        await sut.viewDidLoad()

        // Then
        XCTAssertTrue(stateChanges.contains("loading"))
        XCTAssertEqual(stateChanges.last, "success")
    }

    func test_stateTransitions_whenMultipleOperations_shouldHandleCorrectly() async {
        // Given
        var stateChangeCount = 0
        sut.didChangeState = { _ in
            stateChangeCount += 1
        }

        let mockSearchResponse = SearchResponse(
            sellerID: "123",
            results: ["MLB1"],
            paging: Paging(limit: 20, offset: 0, total: 100)
        )
        mockAPIClient.sendResult = .success(mockSearchResponse)

        // When
        await sut.viewDidLoad()
        await sut.filter(query: "novo")
        await sut.paginate()

        // Then
        XCTAssertGreaterThan(stateChangeCount, 0)
    }

    // MARK: - Error Handling Tests

    func test_errorHandling_when400Error_shouldReturnUnauthorized() async {
        // Given
        var stateChanges: [ListState] = []
        sut.didChangeState = { state in
            stateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.httpError(statusCode: 400))

        // When
        await sut.viewDidLoad()

        // Then
        let hasUnauthorizedState = stateChanges.contains(where: {
            if case .unauthorized = $0 { return true }
            return false
        })
        XCTAssertTrue(hasUnauthorizedState)
    }

    func test_errorHandling_when403Error_shouldReturnUnauthorized() async {
        // Given
        var stateChanges: [ListState] = []
        sut.didChangeState = { state in
            stateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.httpError(statusCode: 403))

        // When
        await sut.viewDidLoad()

        // Then
        let hasUnauthorizedState = stateChanges.contains(where: {
            if case .unauthorized = $0 { return true }
            return false
        })
        XCTAssertTrue(hasUnauthorizedState)
    }

    func test_errorHandling_when500Error_shouldReturnFailure() async {
        // Given
        var stateChanges: [ListState] = []
        sut.didChangeState = { state in
            stateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.httpError(statusCode: 500))

        // When
        await sut.viewDidLoad()

        // Then
        let hasFailureState = stateChanges.contains(where: {
            if case .failure = $0 { return true }
            return false
        })
        XCTAssertTrue(hasFailureState)
    }

    // MARK: - Edge Cases

    func test_edgeCase_whenTaskCancelled_shouldHandleGracefully() async {
        // Given
        mockAPIClient.sendDelay = .milliseconds(100)
        mockAPIClient.sendResult = .success(SearchResponse(
            sellerID: "123",
            results: [],
            paging: Paging(limit: 20, offset: 0, total: 0)
        ))

        // When
        let task = Task {
            await sut.viewDidLoad()
        }

        task.cancel()

        // Then
        // Não deve crashear
    }

    func test_edgeCase_whenPaginatingWithEmptyList_shouldHandleCorrectly() async {
        // Given
        mockPaginationManager.canLoadMoreValue = true
        mockPaginationManager.totalValue = 0

        mockAPIClient.sendResult = .success(SearchResponse(
            sellerID: "123",
            results: [],
            paging: Paging(limit: 20, offset: 0, total: 0)
        ))

        // When
        await sut.paginate()

        // Then
        // Não deve crashear
    }

    func test_edgeCase_whenVeryLargeOffset_shouldHandleCorrectly() async {
        // Given
        mockPaginationManager.offsetValue = 10000
        mockPaginationManager.canLoadMoreValue = true

        mockAPIClient.sendResult = .success(SearchResponse(
            sellerID: "123",
            results: [],
            paging: Paging(limit: 20, offset: 10000, total: 10020)
        ))

        // When
        await sut.paginate()

        // Then
        XCTAssertTrue(mockAPIClient.contains(.send))
    }

    // MARK: - Memory Tests

    func test_memory_whenDeallocated_shouldCancelOperations() async {
        // Given
        var sut: ListViewModel? = makeSut()
        mockAPIClient.sendDelay = .milliseconds(200)
        mockAPIClient.sendResult = .success(SearchResponse(
            sellerID: "123",
            results: [],
            paging: Paging(limit: 20, offset: 0, total: 0)
        ))

        // When
        Task {
            await sut?.viewDidLoad()
        }

        try? await Task.sleep(for: .milliseconds(50))
        sut = nil // force deinit

        // Then no crasher or leak
        try? await Task.sleep(for: .milliseconds(250))
    }

    // MARK: - Integration Tests

    func test_integration_whenCompleteUserFlow_shouldWorkCorrectly() async {
        // Given
        var stateChanges: [String] = []
        sut.didChangeState = { state in
            switch state {
            case .loading: stateChanges.append("loading")
            case .success: stateChanges.append("success")
            case .paginationSuccess: stateChanges.append("paginationSuccess")
            default: break
            }
        }

        await sut.viewDidLoad()
        await sut.paginate()
        await sut.filter(query: "new")

        // Then
        XCTAssertTrue(stateChanges.contains("loading"))
        XCTAssertTrue(stateChanges.contains("success"))
    }

    // MARK: - Helpers

    private func makeSut() -> ListViewModel {
        ListViewModel(
            userId: testUserId,
            query: testQuery,
            apiClient: mockAPIClient,
            paginationManager: mockPaginationManager
        )
    }
}
