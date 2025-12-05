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
    case empty(displayModel: FeedbackViewDisplayModel)
    case success(items: [ItemResponse])
    case paginationSuccess(items: [ItemResponse])
    case failure(displayModel: FeedbackViewDisplayModel)
    case unauthorized
    case refresh
    case retry
}

enum ListLoadingState: Equatable {
    case idle
    case loadingInitial
    case loadingMore
    case searching

    var canLoadMore: Bool {
        self == .idle
    }

    var canSearch: Bool {
        self == .idle || self == .loadingMore
    }

    var isLoading: Bool {
        self != .idle
    }
}

enum ListOperationContext {
    case initialLoad
    case search(query: String)
    case pagination

    var isInitialOrSearch: Bool {
        switch self {
        case .initialLoad, .search:
            return true

        case .pagination:
            return false
        }
    }
}

enum ListError: LocalizedError {
    case emptyResults
    case alreadyLoading
    case cannotPaginate
    case invalidState
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

    private let stateLock = NSLock()

    private var _itemsResponse: [ItemResponse] = []
    private var _loadingState: ListLoadingState = .idle

    private var itemsResponse: [ItemResponse] {
        get {
            stateLock.lock()
            defer { stateLock.unlock() }
            return _itemsResponse
        }
        set {
            stateLock.lock()
            defer { stateLock.unlock() }
            _itemsResponse = newValue
        }
    }

    private var loadingState: ListLoadingState {
        get {
            stateLock.lock()
            defer { stateLock.unlock() }
            return _loadingState
        }
        set {
            stateLock.lock()
            let oldValue = _loadingState
            _loadingState = newValue
            stateLock.unlock()

            Logger.log(
                title: "ListViewModel.loadingState",
                message: "Changed: \(oldValue) -> \(newValue)",
                type: .debug
            )
        }
    }

    private(set) var state: ListState = .idle {
        didSet {
            didChangeState?(self.state)
        }
    }

    // MARK: - ListViewModelProtocol Properties

    var query: String
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
    private func executeOperation(_ context: ListOperationContext) async {
        guard canExecute(context) else {
            return
        }

        prepareForOperation(context)
        await performFetch(context: context)
    }

    private func canExecute(_ context: ListOperationContext) -> Bool {
        switch context {
        case .initialLoad:
            return true

        case .search:
            guard loadingState.canSearch else {
                Logger.log(title: "ListViewModel.canExecute", message: "Cannot search in state: \(loadingState)")
                return false
            }

            return true

        case .pagination:
            guard loadingState.canLoadMore else {
                Logger.log(title: "ListViewModel.canExecute", message: "Cannot paginate in state: \(loadingState)")
                return false
            }

            paginationManager.nextPage()
            guard paginationManager.canLoadMore else {
                Logger.log(title: "ListViewModel.canExecute", message: "No more pages to load")
                return false
            }

            return true
        }
    }

    private func prepareForOperation(_ context: ListOperationContext) {
        switch context {
        case .initialLoad:
            loadingState = .loadingInitial
            state = .loading

        case .search(let newQuery):
            loadingState = .searching
            state = .loading

            paginationManager.reset()
            query = newQuery

        case .pagination:
            loadingState = .loadingMore
        }
    }
}

// MARK: - Data Fetching

extension ListViewModel {
    private func performFetch(context: ListOperationContext) async {
        defer {
            loadingState = .idle
        }

        guard !Task.isCancelled else {
            Logger.log(title: "ListViewModel.performFetch", message: "Task cancelled before fetch")
            return
        }

        do {
            let items = try await requestData()

            guard !Task.isCancelled else {
                Logger.log(title: "ListViewModel.performFetch", message: "Task cancelled after fetch")
                return
            }

            handleSuccess(items: items, context: context)

        } catch let error as APIError {
            guard !Task.isCancelled else {
                return
            }

            handleAPIError(error, context: context)

        } catch let error as ListError {
            guard !Task.isCancelled else {
                return
            }

            if case .emptyResults = error {
                handleEmptyResults(context: context)
                return
            }

            handleGenericError(context: context)

        } catch {
            guard !Task.isCancelled else {
                return
            }

            handleGenericError(context: context)
        }
    }

    private func requestData() async throws -> [ItemResponse] {
        let searchRequest = SearchRequest(
            userId: userId,
            offset: paginationManager.offset,
            limit: paginationManager.limit,
            query: query
        )

        let searchResponse = try await apiClient.send(searchRequest)
        paginationManager.updateTotal(searchResponse.paging.total)

        guard !searchResponse.results.isEmpty else {
            Logger.log(title: "ListViewModel.requestData", message: "Empty results for query: '\(query)'", type: .info)
            throw ListError.emptyResults
        }

        let itemsRequest = ItemsRequest(itemsId: searchResponse.results)
        return try await apiClient.send(itemsRequest)
    }
}

// MARK: - Success Handlers

extension ListViewModel {
    private func handleSuccess(items: [ItemResponse], context: ListOperationContext) {
        guard !items.isEmpty else {
            handleEmptyResults(context: context)
            return
        }

        switch context {
        case .initialLoad, .search:
            itemsResponse = items
            state = .success(items: items)

        case .pagination:
            var currentItems = itemsResponse
            currentItems.append(contentsOf: items)
            itemsResponse = currentItems
            state = .paginationSuccess(items: items)
        }

        Logger.log(
            title: "ListViewModel.handleSuccess",
            message: "Loaded \(items.count) items. Total: \(itemsResponse.count)",
            type: .info
        )
    }

    private func handleEmptyResults(context: ListOperationContext) {
        switch context {
        case .initialLoad, .search:
            let displayModel = createEmptyStateDisplayModel()
            state = .empty(displayModel: displayModel)

        case .pagination:
            Logger.log(title: "ListViewModel.handleEmptyResults", message: "No more items to paginate")
        }
    }

    private func createEmptyStateDisplayModel() -> FeedbackViewDisplayModel {
        let message: String
        if !query.isEmpty {
            message = Localized.List.Feedback.Empty.Message.query(query)
        } else {
            message = Localized.List.Feedback.Empty.message
        }

        return FeedbackViewDisplayModel(
            iconName: Localized.Icon.empty,
            title: Localized.List.Feedback.Empty.title,
            message: message,
            actionButtonTitle: Localized.List.Feedback.Empty.Button.title,
            action: { [weak self] in
                self?.state = .refresh
            }
        )
    }
}

// MARK: - Error Handlers

extension ListViewModel {
    private func handleAPIError(_ error: APIError, context: ListOperationContext) {
        Logger.log(
            title: "ListViewModel.handleAPIError",
            message: "Error: \(error), Context: \(context)",
            type: .error
        )

        if error.isAuthenticationError {
            handleUnauthorized()
            return
        }

        handleGenericError(context: context)
    }

    private func handleUnauthorized() {
        Logger.log(
            title: "ListViewModel.handleUnauthorized",
            message: "Authentication error - clearing data",
            type: .error
        )

        itemsResponse = []
        state = .unauthorized
    }

    private func handleGenericError(context: ListOperationContext) {
        Logger.log(
            title: "ListViewModel.handleGenericError",
            message: "Generic error for context: \(context)",
            type: .error
        )

        let displayModel = createErrorDisplayModel(context: context)
        state = .failure(displayModel: displayModel)
    }

    private func createErrorDisplayModel(context: ListOperationContext) -> FeedbackViewDisplayModel {
        let title: String
        let message: String

        switch context {
        case .initialLoad:
            title = Localized.List.Feedback.Error.InitialLoad.title
            message = Localized.List.Feedback.Error.InitialLoad.message

        case .search:
            title = Localized.List.Feedback.Error.Search.title
            message = Localized.List.Feedback.Error.Search.message

        case .pagination:
            title = Localized.List.Feedback.Error.Pagination.title
            message = Localized.List.Feedback.Error.Pagination.message
        }

        return FeedbackViewDisplayModel(
            iconName: Localized.Icon.error,
            title: title,
            message: message,
            actionButtonTitle: Localized.Button.retry,
            action: { [weak self] in
                self?.state = .retry
            }
        )
    }
}

// MARK: - ListViewModelProtocol

extension ListViewModel: ListViewModelProtocol {
    func viewDidLoad() async {
        await executeOperation(.initialLoad)
    }

    func paginate() async {
        await executeOperation(.pagination)
    }

    func filter(query: String) async {
        guard query != self.query else {
            Logger.log(title: "ListViewModel.filter", message: "Query unchanged, skipping: '\(query)'")

            return
        }

        await executeOperation(.search(query: query))
    }

    func getItem(at index: Int) -> ItemResponse? {
        itemsResponse.indices.contains(index) ? itemsResponse[index] : nil
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension ListViewModel {
    var debugDescription: String {
        """
        ListViewModel Debug:
        - userId: \(userId)
        - query: '\(query)'
        - loadingState: \(loadingState)
        - itemsCount: \(itemsResponse.count)
        - pagination: offset=\(paginationManager.offset), total=\(paginationManager.total)
        """
    }

    /// Forces a specific state (for testing purposes only)
    func forceState(_ state: ListState) {
        self.state = state
    }
}
#endif
