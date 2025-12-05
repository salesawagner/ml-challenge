//
//  LoginViewModel.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

enum LoginState {
    case idle
    case loading
    case success(userId: Int)
    case failure(displayModel: ErrorViewDisplayModel)
    case retry
}

protocol LoginViewModelProtocol {
    var didChangeState: ((LoginState) -> Void)? { get set }

    func fetchLogin() async
}

final class LoginViewModel {
    // MARK: - Properties

    private let apiClient: APIClientProtocol
    private let tokenManager: TokenStorageProtocol
    private var tokenResponse: TokenRequest.Response?

    // MARK: - DetailViewModelProtocol Properties

    private(set) var state: LoginState = .loading { // FIXME: Idle
        didSet {
            didChangeState?(state)
        }
    }

    var didChangeState: ((LoginState) -> Void)?

    // MARK: - Initialization

    init(
        apiClient: APIClientProtocol = DependencyContainer.shared.apiClient,
        tokenManager: TokenStorageProtocol = DependencyContainer.shared.tokenManager
    ) {
        self.apiClient = apiClient
        self.tokenManager = tokenManager
    }

    // MARK: - Private Methods

    private func performFetchToken() async {
        state = .loading

        do {
            let tokenResponse = try await requestData()
            try tokenManager.saveToken(tokenResponse)

            state = .success(userId: tokenResponse.userId)
        } catch {
            handleGenericError()
        }
    }

    private func requestData() async throws -> TokenRequest.Response {
        guard let refreshToken = try? tokenManager.retrieveRefreshToken() else {
            throw APIError.invalidParam
        }

        let refreshTokenRequest = RefreshTokenRequest(
            clientId: AppConfiguration.clientId,
            clientSecret: AppConfiguration.clientSecret,
            redirectUri: AppConfiguration.redirectURI,
            refreshToken: refreshToken
        )

        return try await apiClient.send(refreshTokenRequest)
    }

    private func handleGenericError() {
        let displayModel = ErrorViewDisplayModel(
            title: "Não foi possível carregar", // FIXME: textos
            message: "Tivemos um problema ao carregar o conteúdo. Tente novamente.",
            iconName: "arrow.clockwise.circle",
            primaryButtonTitle: "Recarregar",
            primaryAction: { [weak self] in
                self?.state = .retry
            }
        )

        state = .failure(displayModel: displayModel)
    }
}

// MARK: - DetailViewModelProtocol

extension LoginViewModel: LoginViewModelProtocol {
    func fetchLogin() async {
        await performFetchToken()
    }
}
