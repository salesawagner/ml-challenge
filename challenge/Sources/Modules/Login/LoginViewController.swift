//
//  LoginViewController.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import UIKit

final class LoginViewController: UIViewController {
    // MARK: - Properties

    private var viewModel: LoginViewModelProtocol
    private let contentView: LoginViewContent
    private var currentTask: Task<Void, Never>?

    // MARK: - Initialization

    init(viewModel: LoginViewModelProtocol = LoginViewModel(), contentView: LoginViewContent = LoginView()) {
        self.viewModel = viewModel
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
        setups()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    deinit {
        currentTask?.cancel()
        viewModel.didChangeState = nil
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = contentView
    }

    // MARK: - Setups

    private func setups() {
        setupNavigation()
        setupView()
        setupContentView()
        setupViewModel()
    }

    private func setupNavigation() {
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    private func setupView() {
        title = Localized.Login.title
    }

    private func setupViewModel() {
        viewModel.didChangeState = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleStateChange(state)
            }
        }
    }

    private func setupContentView() {
        contentView.delegate = self
    }

    // MARK: - Private Methods

    private func performLogin() {
        currentTask = Task {
            await viewModel.fetchLogin()
        }
    }
}

// MARK: - Handlers

extension LoginViewController {
    private func handleStateChange(_ state: LoginState) {
        switch state {
        case .idle:
            handleIdleState()

        case .loading:
            handleLoadingState()

        case .success(let userId):
            handleSuccessState(userId: userId)

        case .failure(let displayModel):
            handleFailureState(displayModel: displayModel)

        case .retry:
            performLogin()
        }
    }

    private func handleIdleState() {
        contentView.hideLoading()
    }

    private func handleLoadingState() {
        contentView.showLoading()
    }

    private func handleSuccessState(userId: Int) {
        contentView.hideLoading()

        let viewModel = SearchViewModel(userId: userId)
        let searchViewController = SearchViewController(viewModel: viewModel)
        navigationController?.pushViewController(searchViewController, animated: true)
    }

    private func handleFailureState(displayModel: FeedbackViewDisplayModel) {
        let errorViewController = FeedbackViewController(displayModel: displayModel)
        present(errorViewController, animated: true)
    }
}

// MARK: - LoginViewDelegate

extension LoginViewController: LoginViewDelegate {
    func actionButtonTapped() {
        performLogin()
    }
}
