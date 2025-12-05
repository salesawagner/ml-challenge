//
//  DetailViewModel.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

enum DetailState {
    case idle
    case displayingItem(item: ItemResponse)
    case loading
    case success(description: ItemDescriptionResponse)
    case failure
    case descriptionError(displayModel: FeedbackViewDisplayModel)
    case unauthorized
}

protocol DetailViewModelProtocol {
    var didChangeState: ((DetailState) -> Void)? { get set }

    func viewDidLoad() async
    func fetchDescription() async
}

final class DetailViewModel {
    // MARK: - Properties

    private let itemResponse: ItemResponse
    private let apiClient: APIClientProtocol

    // MARK: - DetailViewModelProtocol Properties

    private(set) var state: DetailState = .idle {
        didSet {
            didChangeState?(state)
        }
    }

    var didChangeState: ((DetailState) -> Void)?

    // MARK: - Initialization

    init(itemResponse: ItemResponse, apiClient: APIClientProtocol = DependencyContainer.shared.apiClient) {
        self.itemResponse = itemResponse
        self.apiClient = apiClient
    }

    // MARK: - Private Methods

    private func performFetchDescription() async {
        state = .loading

        do {
            let description = try await requestData()
            state = .success(description: description)
        } catch let error as APIError {
            handleApiError(error)
        } catch {
            handleGenericError()
        }
    }

    private func requestData() async throws -> ItemDescriptionRequest.Response {
        let itemDescriptionRequest = ItemDescriptionRequest(itemId: itemResponse.id)
        return try await apiClient.send(itemDescriptionRequest)
    }
}

// MARK: - Handlers

extension DetailViewModel {
    private func handleApiError(_ error: APIError) {
        guard error.isAuthenticationError else {
            handleGenericError()
            return
        }

        state = .unauthorized
    }

    private func handleGenericError() {
        let displayModel = FeedbackViewDisplayModel(
            title: "Algo deu errado",
            message: "Não foi possível carregar a descrição do produto",
            actionButtonTitle: "Tentar novamente",
            action: { [weak self] in
                Task {
                    await self?.fetchDescription()
                }
            }
        )

        state = .descriptionError(displayModel: displayModel)
    }
}

// MARK: - DetailViewModelProtocol

extension DetailViewModel: DetailViewModelProtocol {
    func viewDidLoad() async {
        state = .displayingItem(item: itemResponse)

        await fetchDescription()
    }

    func fetchDescription() async {
        await performFetchDescription()
    }
}
