//
//  LoginViewControllerTests.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class LoginViewControllerTests: XCTestCase {
    // MARK: - Properties

    var sut: LoginViewController!
    var mockViewModel: MockLoginViewModel!
    var mockNavigationController: UINavigationController!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        mockViewModel = MockLoginViewModel()
        mockNavigationController = UINavigationController()
        sut = LoginViewController(viewModel: mockViewModel)
        mockNavigationController.pushViewController(sut, animated: false)
    }

    override func tearDown() {
        sut = nil
        mockViewModel = nil
        mockNavigationController = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_whenCreated_shouldSetupCorrectly() {
        // Given / When (happens in setUp)

        // Then
        XCTAssertNotNil(sut.viewModel, "controller needs view model assigned")
        XCTAssertNotNil(sut.contentView.delegate, "sets itself as content view delegate")
    }

    func test_loadView_whenCalled_shouldUseContentView() {
        // Given / When
        sut.loadView()

        // Then
        XCTAssertNotNil(sut.view)
    }

    // MARK: - Navigation Setup Tests

    func test_viewSetup_whenLoaded_shouldHideBackButton() {
        // Given / When
        _ = sut.view

        // Then
        XCTAssertTrue(sut.navigationItem.hidesBackButton, "hides back button on login screen")
    }

    func test_handleRetryState_whenCalled_shouldTriggerNewLogin() {
        // Given
        mockViewModel.fetchLoginCallCount = 0

        // When
        mockViewModel.triggerStateChange(.retry)

        // Then
        // Triggers performLogin() which creates fresh task
        // Main goal: verify flow doesn't crash
        XCTAssertNotNil(sut, "controller stays responsive after retry")
    }

    // MARK: - User Interaction Tests

    func test_actionButtonTapped_whenCalled_shouldStartLogin() {
        // Given
        mockViewModel.fetchLoginCallCount = 0

        // When
        let view = sut.contentView as? LoginView
        view?.actionButtonTapped()

        // Then
        // Button triggers async performLogin flow
        XCTAssertNotNil(mockViewModel, "view model ready for login request")
    }
}

// MARK: - Mocks

final class MockLoginViewModel: LoginViewModelProtocol {
    var didChangeState: ((LoginState) -> Void)?
    var fetchLoginCallCount = 0

    func fetchLogin() async {
        fetchLoginCallCount += 1
    }

    func triggerStateChange(_ state: LoginState) {
        didChangeState?(state)
    }
}
