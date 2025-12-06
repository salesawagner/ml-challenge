//
//  DetailViewModelTests.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class DetailViewModelTests: XCTestCase {
    // MARK: - Properties

    var sut: DetailViewModel!
    var mockAPIClient: MockAPIClient!
    var mockItemResponse: ItemResponse!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockItemResponse = TestFixtures.mockItemResponse
        sut = makeSut()
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        mockItemResponse = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_whenCreated_shouldSetDefaultStates() {
        // Given / When (in setUp)

        // Then
        if case .idle = sut.contentState {
            // OK
        } else {
            XCTFail("contentState should be idle initially")
        }

        if case .idle = sut.descriptionState {
            // OK
        } else {
            XCTFail("descriptionState should be idle initially")
        }
    }

    // MARK: - viewDidLoad Tests

    func test_viewDidLoad_whenCalled_shouldEmitDisplayingItem() async {
        // Given
        var contentStateChanges: [DetailContentState] = []
        sut.didChangeContentState = { state in
            contentStateChanges.append(state)
        }

        // When
        await sut.viewDidLoad()

        // Then
        let hasDisplayingItem = contentStateChanges.contains(where: {
            if case .displayingItem = $0 { return true }
            return false
        })
        XCTAssertTrue(hasDisplayingItem, "should emit displayingItem")
    }

    func test_viewDidLoad_whenCalled_shouldStartFetchingDescription() async {
        // Given
        var descriptionStateChanges: [DetailDescriptionState] = []
        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)

        // When
        await sut.viewDidLoad()

        // Then
        let hasLoadingState = descriptionStateChanges.contains(where: {
            if case .loading = $0 { return true }
            return false
        })
        XCTAssertTrue(hasLoadingState, "should emit loading for description")
    }

    func test_viewDidLoad_whenDescriptionSuccess_shouldEmitSuccess() async {
        // Given
        let mockDescription = TestFixtures.mockItemDescriptionResponse
        var descriptionStateChanges: [DetailDescriptionState] = []
        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .success(mockDescription)

        // When
        await sut.viewDidLoad()

        // Then
        let hasSuccessState = descriptionStateChanges.contains(where: {
            if case .success(let desc) = $0 {
                return desc.plainText == mockDescription.plainText
            }
            return false
        })
        XCTAssertTrue(hasSuccessState, "should emit success with description")
    }

    func test_viewDidLoad_whenDescriptionFails_shouldEmitError() async {
        // Given
        var descriptionStateChanges: [DetailDescriptionState] = []
        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.networkError(URLError(.notConnectedToInternet)))

        // When
        await sut.viewDidLoad()

        // Then
        let hasErrorState = descriptionStateChanges.contains(where: {
            if case .descriptionError = $0 { return true }
            return false
        })
        XCTAssertTrue(hasErrorState, "should emit descriptionError on failure")
    }

    // MARK: - fetchDescription Tests

    func test_fetchDescription_whenSuccessful_shouldReturnDescription() async {
        // Given
        let mockDescription = TestFixtures.mockItemDescriptionResponse
        var descriptionStateChanges: [DetailDescriptionState] = []
        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .success(mockDescription)

        // When
        await sut.fetchDescription()

        // Then
        let hasSuccessState = descriptionStateChanges.contains(where: {
            if case .success = $0 { return true }
            return false
        })
        XCTAssertTrue(hasSuccessState, "should emit success")
        XCTAssertTrue(mockAPIClient.contains(.send), "should make request")
    }

    func test_fetchDescription_whenAuthError_shouldEmitUnauthorized() async {
        // Given
        var descriptionStateChanges: [DetailDescriptionState] = []
        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.httpError(statusCode: 401))

        // When
        await sut.fetchDescription()

        // Then
        let hasUnauthorizedState = descriptionStateChanges.contains(where: {
            if case .unauthorized = $0 { return true }
            return false
        })
        XCTAssertTrue(hasUnauthorizedState, "should emit unauthorized on 401 error")
    }

    func test_fetchDescription_whenNetworkError_shouldEmitError() async {
        // Given
        var descriptionStateChanges: [DetailDescriptionState] = []
        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.networkError(URLError(.notConnectedToInternet)))

        // When
        await sut.fetchDescription()

        // Then
        let hasErrorState = descriptionStateChanges.contains(where: {
            if case .descriptionError = $0 { return true }
            return false
        })
        XCTAssertTrue(hasErrorState, "should emit descriptionError")
    }

    func test_fetchDescription_whenLoading_shouldEmitLoadingState() async {
        // Given
        var descriptionStateChanges: [DetailDescriptionState] = []
        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)

        // When
        await sut.fetchDescription()

        // Then
        let hasLoadingState = descriptionStateChanges.contains(where: {
            if case .loading = $0 { return true }
            return false
        })
        XCTAssertTrue(hasLoadingState, "should emit loading before result")
    }

    // MARK: - State Transitions Tests

    func test_stateTransitions_whenViewDidLoad_shouldFollowCorrectFlow() async {
        // Given
        var contentStates: [String] = []
        var descriptionStates: [String] = []

        sut.didChangeContentState = { state in
            switch state {
            case .idle: contentStates.append("idle")
            case .displayingItem: contentStates.append("displayingItem")
            }
        }

        sut.didChangeDescriptionState = { state in
            switch state {
            case .idle: descriptionStates.append("idle")
            case .loading: descriptionStates.append("loading")
            case .success: descriptionStates.append("success")
            case .descriptionError: descriptionStates.append("error")
            case .unauthorized: descriptionStates.append("unauthorized")
            case .retry: descriptionStates.append("retry")
            }
        }

        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)

        // When
        await sut.viewDidLoad()

        // Then
        XCTAssertTrue(contentStates.contains("displayingItem"), "should display item")
        XCTAssertTrue(descriptionStates.contains("loading"), "should pass through loading")
        XCTAssertEqual(descriptionStates.last, "success", "should end in success")
    }

    func test_stateTransitions_whenRetryAfterError_shouldTriggerFetch() async {
        // Given
        var descriptionStateChanges: [DetailDescriptionState] = []
        var retryTriggered = false

        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
            if case .retry = state {
                retryTriggered = true
            }
        }

        mockAPIClient.sendResult = .failure(.networkError(URLError(.notConnectedToInternet)))
        await sut.fetchDescription()

        // When - Simulate retry
        mockAPIClient.resetMock()
        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)

        if case .descriptionError(let displayModel) = sut.descriptionState {
            displayModel.action?() // Simulate retry button tap
        }

        // Then
        XCTAssertTrue(retryTriggered, "should emit retry state")
    }

    // MARK: - Error Handling Tests

    func test_errorHandling_when400Error_shouldEmitUnauthorized() async {
        // Given
        var descriptionStateChanges: [DetailDescriptionState] = []
        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.httpError(statusCode: 400))

        // When
        await sut.fetchDescription()

        // Then
        let hasUnauthorizedState = descriptionStateChanges.contains(where: {
            if case .unauthorized = $0 { return true }
            return false
        })
        XCTAssertTrue(hasUnauthorizedState, "should treat 400 as unauthorized")
    }

    func test_errorHandling_when403Error_shouldEmitUnauthorized() async {
        // Given
        var descriptionStateChanges: [DetailDescriptionState] = []
        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.httpError(statusCode: 403))

        // When
        await sut.fetchDescription()

        // Then
        let hasUnauthorizedState = descriptionStateChanges.contains(where: {
            if case .unauthorized = $0 { return true }
            return false
        })
        XCTAssertTrue(hasUnauthorizedState, "should treat 403 as unauthorized")
    }

    func test_errorHandling_when500Error_shouldEmitDescriptionError() async {
        // Given
        var descriptionStateChanges: [DetailDescriptionState] = []
        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.httpError(statusCode: 500))

        // When
        await sut.fetchDescription()

        // Then
        let hasErrorState = descriptionStateChanges.contains(where: {
            if case .descriptionError = $0 { return true }
            return false
        })
        XCTAssertTrue(hasErrorState, "should treat 500 as descriptionError")
    }

    func test_errorHandling_whenDecodingError_shouldEmitDescriptionError() async {
        // Given
        var descriptionStateChanges: [DetailDescriptionState] = []
        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .failure(.decodingFailed(
            NSError(domain: "Test", code: -1),
            statusCode: 200
        ))

        // When
        await sut.fetchDescription()

        // Then
        let hasErrorState = descriptionStateChanges.contains(where: {
            if case .descriptionError = $0 { return true }
            return false
        })
        XCTAssertTrue(hasErrorState, "should treat decoding error as descriptionError")
    }

    // MARK: - Edge Cases

    func test_edgeCase_whenTaskCancelled_shouldHandleGracefully() async {
        // Given
        mockAPIClient.sendDelay = .milliseconds(100)
        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)

        // When
        let task = Task {
            await sut.fetchDescription()
        }

        task.cancel()

        // Then
        // Should not crash
    }

    func test_edgeCase_whenMultipleFetchCalls_shouldHandleCorrectly() async {
        // Given
        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)

        // When - multiple calls
        await sut.fetchDescription()
        await sut.fetchDescription()
        await sut.fetchDescription()

        // Then
        XCTAssertEqual(mockAPIClient.sendCallCount, 3, "should make all requests")
    }

    func test_edgeCase_whenItemWithoutId_shouldStillFetch() async {
        // Given
        let itemWithoutValidId = ItemResponse(
            title: "Test",
            id: "",
            thumbnail: "",
            price: 0,
            pictures: []
        )

        sut = DetailViewModel(itemResponse: itemWithoutValidId, apiClient: mockAPIClient)
        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)

        // When
        await sut.fetchDescription()

        // Then
        XCTAssertTrue(mockAPIClient.contains(.send), "should attempt request even with empty id")
    }

    // MARK: - Memory Tests

    func test_memory_whenDeallocated_shouldCancelOperations() async {
        // Given
        var sut: DetailViewModel? = makeSut()
        mockAPIClient.sendDelay = .milliseconds(200)
        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)

        // When
        Task {
            await sut?.fetchDescription()
        }

        try? await Task.sleep(for: .milliseconds(50))
        sut = nil // force deinit

        // Then
        try? await Task.sleep(for: .milliseconds(250))
        // Should not crash or leak memory
    }

    // MARK: - Callback Tests

    func test_callbacks_whenNoCallbackSet_shouldNotCrash() async {
        // Given
        sut.didChangeContentState = nil
        sut.didChangeDescriptionState = nil
        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)

        // When / Then
        await sut.viewDidLoad() // should not crash
        await sut.fetchDescription() // should not crash
    }

    func test_callbacks_whenCallbackSetAfterInit_shouldStillWork() async {
        // Given
        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)

        var callbackCalled = false
        sut.didChangeDescriptionState = { _ in
            callbackCalled = true
        }

        // When
        await sut.fetchDescription()

        // Then
        XCTAssertTrue(callbackCalled, "callback should be called even if set after init")
    }

    // MARK: - Integration Tests

    func test_integration_whenCompleteFlow_shouldWorkCorrectly() async {
        // Given
        var contentStateChanges: [DetailContentState] = []
        var descriptionStateChanges: [DetailDescriptionState] = []

        sut.didChangeContentState = { state in
            contentStateChanges.append(state)
        }

        sut.didChangeDescriptionState = { state in
            descriptionStateChanges.append(state)
        }

        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)

        // When - Complete flow
        await sut.viewDidLoad()

        // Then
        XCTAssertFalse(contentStateChanges.isEmpty, "should have content state changes")
        XCTAssertFalse(descriptionStateChanges.isEmpty, "should have description state changes")

        let hasDisplayingItem = contentStateChanges.contains(where: {
            if case .displayingItem = $0 { return true }
            return false
        })
        XCTAssertTrue(hasDisplayingItem, "should display item")

        let hasSuccess = descriptionStateChanges.contains(where: {
            if case .success = $0 { return true }
            return false
        })
        XCTAssertTrue(hasSuccess, "should load description successfully")
    }

    func test_integration_whenErrorThenRetry_shouldWorkCorrectly() async {
        // Given
        var stateChanges: [String] = []
        sut.didChangeDescriptionState = { state in
            switch state {
            case .loading: stateChanges.append("loading")
            case .descriptionError: stateChanges.append("error")
            case .success: stateChanges.append("success")
            case .retry: stateChanges.append("retry")
            default: break
            }
        }

        // When - First fetch fails
        mockAPIClient.sendResult = .failure(.networkError(URLError(.notConnectedToInternet)))
        await sut.fetchDescription()

        // Then
        XCTAssertTrue(stateChanges.contains("error"), "should have error first")

        // When - Retry with success
        stateChanges.removeAll()
        mockAPIClient.sendResult = .success(TestFixtures.mockItemDescriptionResponse)
        await sut.fetchDescription()

        // Then
        XCTAssertTrue(stateChanges.contains("success"), "should have success on retry")
    }

    // MARK: - Helpers

    private func makeSut() -> DetailViewModel {
        DetailViewModel(itemResponse: mockItemResponse, apiClient: mockAPIClient)
    }
}
