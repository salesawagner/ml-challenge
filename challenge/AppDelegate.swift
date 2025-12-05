//
//  AppDelegate.swift
//  challenge
//
//  Created by Wagner Sales
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        saveRefreshTokenIfNeeded()
        AppConfiguration.printConfiguration()
        DependencyContainer.shared.tokenManager.printConfiguration()

        window = UIWindow()

        let loginViewController = LoginViewController()
        let splashViewController = SplashViewController()
        let navigationController = UINavigationController(rootViewController: splashViewController)
        navigationController.viewControllers = [loginViewController, splashViewController]

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    private func saveRefreshTokenIfNeeded() {
        let tokenManager = DependencyContainer.shared.tokenManager
        guard !tokenManager.hasRefreshToken() else {
            return
        }

        try? tokenManager.saveRefreshToken(AppConfiguration.refreshToken)
    }
}
