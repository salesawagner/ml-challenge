//
//  ListViewModel.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import Foundation

enum ListState {
    case idle
    case loading
    case empty(displayModel: EmptyStateViewDisplayModel)
    case success(items: [ItemResponse])
    case paginationSuccess(items: [ItemResponse])
    case failure(displayModel: ErrorViewDisplayModel)
    case unauthorized
    case refresh
    case retry
}

enum ListOperation {
    case paginate
    case filter(query: String)
}

protocol ListViewModelProtocol {
    var query: String { get set }
    var didChangeState: ((ListState) -> Void)? { get set }

    func viewDidLoad() async
    func paginate() async
    func filter(query: String) async
    func getItem(at index: Int) -> ItemResponse?
}

final class ListViewModel {
    // MARK: - Properties

    private let userId: Int
    private let apiClient: APIClientProtocol
    private let paginationManager: ListPaginationManagerProtocol

    private var lastOperation: ListOperation?
    private var itemsResponse: [ItemResponse] = []

    private var isLoadingMore = false
    private var isSearching = false

    // MARK: - ListViewModelProtocol Properties
    var query: String
    private(set) var state: ListState = .idle {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.didChangeState?(self.state)
            }
        }
    }

    var didChangeState: ((ListState) -> Void)?

    // MARK: - Initialization

    init(
        userId: Int,
        query: String,
        apiClient: APIClientProtocol = DependencyContainer.shared.apiClient,
        paginationManager: ListPaginationManagerProtocol = ListPaginationManager()
    ) {
        self.userId = userId
        self.query = query
        self.apiClient = apiClient
        self.paginationManager = paginationManager
    }

    // MARK: - Private Methods

    private func setLoadingState() {
        state = .loading
    }
}

// MARK: - Operations

extension ListViewModel {
    private func execute(_ operation: ListOperation) async {
        lastOperation = operation

        switch operation {
        case .paginate:
            await performPagination()

        case .filter(let query):
            await performSearch(query: query)
        }
    }

    private func performPagination() async {
        defer {
            isLoadingMore = false
        }

        guard !isLoadingMore else {
            Logger.log(title: "performPagination", message: "Already loading", type: .debug)
            return
        }

        paginationManager.nextPage()
        guard paginationManager.canLoadMore else {
            return
        }

        isLoadingMore = true
        await fetchData()
    }

    private func performSearch(query: String) async {
        defer {
            isSearching = false
        }

        guard !isSearching else {
            Logger.log(title: "performSearch", message: "Already searching", type: .debug)
            return
        }

        setLoadingState()
        paginationManager.reset()
        self.query = query

        await fetchData()
    }

    private func fetchData() async {
        guard !Task.isCancelled else {
            return
        }

        do {
            let items = try await requestData()

            handleSuccessfulFetch(items: items)

        } catch let error as APIError {
            guard !Task.isCancelled else {
                return
            }

            handleApiError(error)

        } catch {
            guard !Task.isCancelled else {
                return
            }

            handleGenericError()
        }
    }

    private func requestData() async throws -> ItemsRequest.Response {
        let searchRequest = SearchRequest(
            userId: userId,
            offset: paginationManager.offset,
            limit: paginationManager.limit,
            query: query
        )

        let searchResponse = try await apiClient.send(searchRequest)
        paginationManager.updateTotal(searchResponse.paging.total)

        if searchResponse.results.isEmpty {
            Logger.log(title: "Result Vazio", message: searchRequest.toJSON, type: .info)
            throw APIError.empty
        }

        let itemsRequest = ItemsRequest(itemsId: searchResponse.results)
        return try await apiClient.send(itemsRequest)
    }
}

// MARK: - Handlers

extension ListViewModel {
    private func handleSuccessfulFetch(items: [ItemResponse]) {
        guard !items.isEmpty else {
            handleEmptyState()
            return
        }

        guard let lastOperation else {
            handleGenericError()
            return
        }

        switch lastOperation {
        case .filter:
            itemsResponse = items
            state = .success(items: items)

        case .paginate:
            itemsResponse.append(contentsOf: items)
            state = .paginationSuccess(items: items)
        }
    }

    private func handleApiError(_ error: APIError) {
        if error.isAuthenticationError {
            state = .unauthorized
            return
        }

        if case .empty = error {
            handleSuccessfulFetch(items: [])
        } else {
            handleGenericError()
        }
    }

    private func handleEmptyState() {
        let message: String
        if !query.isEmpty {
            message = "Não encontramos resultados para \(query)"
        } else {
            message = "Não encontramos resultados"
        }

        state = .empty(displayModel: EmptyStateViewDisplayModel(
            iconName: "magnifyingglass",
            title: "Nenhum resultado",
            message: message,
            actionButtonTitle: "limpar busca",
            action: { [weak self] in
                guard let self = self else { return }
                self.state = .refresh
            }
        ))
    }

    private func handleGenericError() {
        Logger.log(title: "handleGenericError", message: "Erro Generico", type: .error)

        state = .failure(displayModel: ErrorViewDisplayModel(
            title: "Não foi possível carregar", // FIXME: Colocar no viewmodel
            message: "Tivemos um problema ao carregar o conteúdo. Tente novamente.",
            iconName: "arrow.clockwise.circle",
            primaryButtonTitle: "Recarregar",
            primaryAction: { [weak self] in
                self?.state = .retry
            }
        ))
    }

    private func retryAction() -> () -> Void {
        { [weak self] in
            guard let self = self else {
                return
            }

            Task {
                await self.retryLastOperation()
            }
        }
    }

    private func retryLastOperation() async {
        guard let lastOperation else {
             return
        }

        await execute(lastOperation)
    }
}

// MARK: - ListViewModelProtocol

extension ListViewModel: ListViewModelProtocol {
    func viewDidLoad() async {
        await execute(.filter(query: query))
    }

    func paginate() async {
        await execute(.paginate)
    }

    func filter(query: String) async {
        guard query != self.query else {
            return
        }

        Logger.log(title: "updateSearchResults", message: "query: \(query)<-- \n self.query: \(self.query)", type: .fault)
        await execute(.filter(query: query))
    }

    func getItem(at index: Int) -> ItemResponse? {
        itemsResponse.indices.contains(index) ? itemsResponse[index] : nil
    }
}
