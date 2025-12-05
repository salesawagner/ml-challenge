//
//  DetailViewModel.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

enum DetailContentState {
    case idle
    case displayingItem(item: ItemResponse)
}

enum DetailDescriptionState {
    case idle
    case loading
    case success(description: ItemDescriptionResponse)
    case descriptionError(displayModel: FeedbackViewDisplayModel)
    case unauthorized
    case retry
}

protocol DetailViewModelProtocol {
    var didChangeContentState: ((DetailContentState) -> Void)? { get set }
    var didChangeDescriptionState: ((DetailDescriptionState) -> Void)? { get set }

    func viewDidLoad() async
    func fetchDescription() async
}

final class DetailViewModel {
    // MARK: - Properties

    private let itemResponse: ItemResponse
    private let apiClient: APIClientProtocol

    private(set) var contentState: DetailContentState = .idle {
        didSet {
            didChangeContentState?(contentState)
        }
    }

    private(set) var descriptionState: DetailDescriptionState = .idle {
        didSet {
            didChangeDescriptionState?(descriptionState)
        }
    }

    // MARK: - DetailViewModelProtocol Properties

    var didChangeContentState: ((DetailContentState) -> Void)?
    var didChangeDescriptionState: ((DetailDescriptionState) -> Void)?

    // MARK: - Initialization

    init(itemResponse: ItemResponse, apiClient: APIClientProtocol = DependencyContainer.shared.apiClient) {
        self.itemResponse = itemResponse
        self.apiClient = apiClient
    }

    // MARK: - Private Methods

    private func performFetchDescription() async {
        descriptionState = .loading

        do {
            let description = try await requestData()
            descriptionState = .success(description: description)
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

        descriptionState = .unauthorized
    }

    private func handleGenericError() {
        descriptionState = .descriptionError(displayModel: .genericError(action: { [weak self] in
            self?.descriptionState = .retry
        }))
    }
}

// MARK: - DetailViewModelProtocol

extension DetailViewModel: DetailViewModelProtocol {
    func viewDidLoad() async {
        contentState = .displayingItem(item: itemResponse)

        await fetchDescription()
    }

    func fetchDescription() async {
        await performFetchDescription()
    }
}
