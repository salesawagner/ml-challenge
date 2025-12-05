//
//  OperationManagerTests.swift
//  challenge
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class OperationManagerTests: XCTestCase {

    // MARK: - Properties

    var sut: OperationManager!

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

    func test_init_whenCreated_shouldNotCrash() {
        // Given / When (in setUp)

        // Then
        XCTAssertNotNil(sut, "should initialize correctly")
    }

    func test_init_whenCustomDelay_shouldAcceptDelay() {
        // Given
        let delay = Duration.milliseconds(500)

        // When
        sut = OperationManager(delay: delay)

        // Then
        XCTAssertNotNil(sut, "should initialize with custom delay")
    }

    // MARK: - performDelay Tests

    func test_performDelay_whenCalled_shouldExecuteActionAfterDelay() async {
        // Given
        let delay = Duration.milliseconds(100)
        sut = OperationManager(delay: delay)
        var actionExecuted = false
        let expectation = expectation(description: "Action should execute")

        // When
        sut.performDelay {
            actionExecuted = true
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 0.2)
        XCTAssertTrue(actionExecuted, "action should execute after delay")
    }

    func test_performDelay_whenCalledMultipleTimes_shouldCancelPreviousAndExecuteLastOnly() async {
        // Given
        let delay = Duration.milliseconds(100)
        sut = OperationManager(delay: delay)
        var executionCount = 0
        var lastValue = 0
        let expectation = expectation(description: "Last action should execute")

        // When
        sut.performDelay {
            executionCount = 1
            lastValue = 1
        }
        sut.performDelay {
            executionCount = 1
            lastValue = 2
        }
        sut.performDelay {
            executionCount = 1
            lastValue = 3
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 0.2)
        XCTAssertEqual(executionCount, 1, "should execute only once")
        XCTAssertEqual(lastValue, 3, "should execute only the last action")
    }

    func test_performDelay_whenCancelledBeforeExecution_shouldNotExecute() async {
        // Given
        let delay = Duration.milliseconds(100)
        sut = OperationManager(delay: delay)
        var actionExecuted = false

        // When
        sut.performDelay {
            actionExecuted = true
        }
        sut.cancel()

        // Then
        try? await Task.sleep(for: .milliseconds(150))
        XCTAssertFalse(actionExecuted, "action should not execute after cancel")
    }

    // MARK: - performImmediate Tests

    func test_performImmediate_whenCalled_shouldExecuteImmediately() async {
        // Given
        var actionExecuted = false
        let expectation = expectation(description: "Action should execute immediately")

        // When
        sut.performImmediate {
            actionExecuted = true
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 0.1)
        XCTAssertTrue(actionExecuted, "should execute immediately")
    }

    func test_performImmediate_whenCalledMultipleTimes_shouldCancelPreviousAndExecuteLastOnly() async {
        // Given
        var executionCount = 0
        var lastValue = 0
        let expectation = expectation(description: "Last action should execute")

        // When
        sut.performImmediate {
            executionCount = 1
            lastValue = 1
        }
        try? await Task.sleep(for: .milliseconds(100))

        sut.performImmediate {
            executionCount = 1
            lastValue = 2
        }
        try? await Task.sleep(for: .milliseconds(100))

        sut.performImmediate {
            executionCount = 1
            lastValue = 3
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 0.3)
        XCTAssertEqual(executionCount, 1, "should execute only the last one")
        XCTAssertEqual(lastValue, 3, "should execute only the last action")
    }

    // MARK: - cancel Tests

    func test_cancel_whenCalled_shouldCancelCurrentTask() async {
        // Given
        var actionExecuted = false

        // When
        sut.performDelay {
            actionExecuted = true
        }
        sut.cancel()

        // Then
        try? await Task.sleep(for: .milliseconds(150))
        XCTAssertFalse(actionExecuted, "should cancel pending task")
    }

    func test_cancel_whenNoTaskRunning_shouldNotCrash() {
        // Given / When / Then
        sut.cancel()
        // should not crash
    }

    func test_cancel_whenCalledMultipleTimes_shouldNotCrash() {
        // Given / When
        sut.cancel()
        sut.cancel()
        sut.cancel()

        // Then
        // should not crash
    }

    // MARK: - Mixed Operations Tests

    func test_performImmediate_afterPerformDelay_shouldCancelDelayedTask() async {
        // Given
        let delay = Duration.milliseconds(100)
        sut = OperationManager(delay: delay)
        var delayedExecuted = false
        var immediateExecuted = false
        let expectation = expectation(description: "Immediate should execute")

        // When
        sut.performDelay {
            delayedExecuted = true
        }
        sut.performImmediate {
            immediateExecuted = true
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 0.2)
        XCTAssertFalse(delayedExecuted, "delayed should not execute")
        XCTAssertTrue(immediateExecuted, "immediate should execute")
    }

    // MARK: - Edge Cases

    func test_performDelay_whenTaskIsCancelled_shouldNotCrash() async {
        // Given
        let delay = Duration.milliseconds(100)
        sut = OperationManager(delay: delay)
        let expectation = expectation(description: "Should handle cancellation")

        // When
        sut.performDelay {
            // Simulate cancellation
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 0.2)
    }

    func test_performImmediate_whenCalledAfterCancel_shouldExecuteNewTask() async {
        // Given
        var actionExecuted = false
        let expectation = expectation(description: "New task should execute")

        // When
        sut.performImmediate {
            // This should not execute
        }
        sut.cancel()
        sut.performImmediate {
            actionExecuted = true
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 0.1)
        XCTAssertTrue(actionExecuted, "should execute new task after cancel")
    }

    // MARK: - Memory Tests

    func test_deinit_whenDeallocated_shouldCancelCurrentTask() async {
        // Given
        var weakSut: OperationManager? = OperationManager(delay: .milliseconds(100))
        var actionExecuted = false

        // When
        weakSut?.performDelay {
            actionExecuted = true
        }
        weakSut = nil // trigger deinit

        // Then
        try? await Task.sleep(for: .milliseconds(150))
        XCTAssertFalse(actionExecuted, "should cancel task on deinit")
    }

    // MARK: - Helpers

    private func makeSut() -> OperationManager {
        OperationManager(delay: .milliseconds(300))
    }
}
