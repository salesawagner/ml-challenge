//
//  DependencyContainer.swift
//  challenge
//
//  Created by Wagner Sales
//

final class DependencyContainer {
    static let shared = DependencyContainer()

    let environment: Environment
    let apiClient: APIClientProtocol
    let tokenManager: TokenStorageProtocol
    let imageCache: ImageCache

    private init() {
        environment = EnvironmentFactory.currentEnvironment()
        apiClient = APIClient(environment: environment)
        tokenManager = TokenManager(environment: environment)
        imageCache = ImageCache()
    }
}
