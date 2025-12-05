//
//  SplashViewController.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Properties

    let tokenManager: TokenStorageProtocol

    // MARK: - Initialization

    init(tokenManager: TokenStorageProtocol = DependencyContainer.shared.tokenManager) {
        self.tokenManager = tokenManager
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthAndNavigate()
    }

    // MARK: - Private Methods

    private func checkAuthAndNavigate() {
        guard let navigationController, let loginViewController = navigationController.viewControllers.first else {
            return
        }

        guard tokenManager.isValidToken(), let userId = try? tokenManager.retrieveUserId() else {
            navigationController.popViewController(animated: false)
            return
        }

        let searchViewController = SearchViewController(viewModel: SearchViewModel(userId: userId))
        navigationController.setViewControllers([loginViewController, searchViewController], animated: false)
    }
}
