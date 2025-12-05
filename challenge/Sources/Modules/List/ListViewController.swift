//
//  ListViewController.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import UIKit

final class ListViewController: UIViewController, Navigable {
    // MARK: - Properties

    private var viewModel: ListViewModelProtocol
    private var contentView: ListViewContent
    private let operationManager: OperationManager
    private var displayItems: [ListItemDisplayModel] = []

    private var query: String {
        viewModel.query
    }

    // MARK: - UI Components

    private let searchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = Localized.Search.placeholder

        return searchController
    }()

    // MARK: - Initialization

    init(
        viewModel: ListViewModelProtocol,
        contentView: ListViewContent = ListView(),
        operationManager: OperationManager = OperationManager()
    ) {
        self.viewModel = viewModel
        self.contentView = contentView
        self.operationManager = operationManager

        super.init(nibName: nil, bundle: nil)
        setupViewModel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    deinit {
        operationManager.cancel()
        viewModel.didChangeState = nil
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setups()
        performInitialLoad()
    }

    // MARK: - Setups

    private func setups() {
        setupViewController()
        setupSearchController()
        setupContentView()
    }

    private func setupViewModel() {
        viewModel.didChangeState = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleStateChange(state)
            }
        }
    }

    private func setupViewController() {
        title = Localized.List.title
        navigationItem.largeTitleDisplayMode = .automatic
    }

    private func setupSearchController() {
        searchController.searchBar.text = query
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true
    }

    private func setupContentView() {
        contentView.delegate = self
        contentView.dataSource = self
    }

    // MARK: - Private Methods

    private func performInitialLoad() {
        operationManager.performImmediate { [weak self] in
            await self?.viewModel.viewDidLoad()
        }
    }

    private func performSearch(with query: String) {
        contentView.scrollToTop(animated: true)

        operationManager.performDelay { [weak self] in
            await self?.viewModel.filter(query: query)
        }
    }

    private func performPagination() {
        operationManager.performImmediate { [weak self] in
            await self?.viewModel.paginate()
        }
    }

    private func clearSearch() {
        searchController.searchBar.text = ""
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }

    private func convertToDisplayModels(_ items: [ItemResponse]) -> [ListItemDisplayModel] {
        items.map(ListItemDisplayModel.from)
    }

    private func updateDisplayItems(with items: [ItemResponse], append: Bool) {
        let newDisplayItems = convertToDisplayModels(items)

        if append {
            displayItems.append(contentsOf: newDisplayItems)
            contentView.appendItems(newDisplayItems)
        } else {
            displayItems = newDisplayItems
            contentView.renderItems(newDisplayItems)
        }
    }

    private func clearDisplayItems() {
        displayItems.removeAll()
        contentView.clearItems()
    }

    private func navigateToDetail(with item: ItemResponse) {
        let detailViewModel = DetailViewModel(itemResponse: item)
        let detailViewController = DetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - Handlers

extension ListViewController {
    private func handleStateChange(_ state: ListState) {
        switch state {
        case .idle:
            handleIdleState()

        case .loading:
            handleLoadingState()

        case .empty(let displayModel):
            handleEmptyState(displayModel: displayModel)

        case .success(let itens):
            handleSuccessState(itens)

        case .paginationSuccess(let items):
            handlePaginationSuccessState(items)

        case .failure(let displayModel):
            handleFailureState(displayModel: displayModel)

        case .unauthorized:
            handleUnauthorizedState()

        case .refresh:
            handleRefreshState()

        case .retry:
            handleRetryState()
        }
    }

    private func handleIdleState() {
        contentView.hideLoading()
    }

    private func handleLoadingState() {
        contentView.showLoading()
    }

    private func handleEmptyState(displayModel: FeedbackViewDisplayModel) {
        clearDisplayItems()
        contentView.showEmptyState(with: displayModel)
        contentView.hideLoading()
    }

    private func handleSuccessState(_ items: [ItemResponse]) {
        updateDisplayItems(with: items, append: false)
        contentView.hideEmptyState()
        contentView.hideLoading()
    }

    private func handlePaginationSuccessState(_ items: [ItemResponse]) {
        updateDisplayItems(with: items, append: true)
        contentView.hideLoading()
    }

    private func handleFailureState(displayModel: FeedbackViewDisplayModel) {
        contentView.hideLoading()

        let errorViewController = FeedbackViewController(displayModel: displayModel)
        present(errorViewController, animated: true)
    }

    private func handleUnauthorizedState() {
        clearDisplayItems()
        navigateToLogin()
    }

    private func handleRefreshState() {
        clearSearch()
    }

    private func handleRetryState() {
        performSearch(with: viewModel.query)
    }
}

// MARK: - ListViewDataSource

extension ListViewController: ListViewDataSource {
    var numberOfItems: Int {
        displayItems.count
    }

    func item(at index: Int) -> ListItemDisplayModel? {
        guard displayItems.indices.contains(index) else {
            return nil
        }

        return displayItems[index]
    }
}

// MARK: - ListViewDelegate

extension ListViewController: ListViewDelegate {
    func listViewDidSelectItem(at index: Int) {
        guard let itemResponse = viewModel.getItem(at: index) else {
            Logger.log(
                title: "ListViewController",
                message: "Item not found at index: \(index)",
                type: .error
            )
            return
        }

        navigateToDetail(with: itemResponse)
    }

    func listViewDidReachEnd() {
        performPagination()
    }
}

// MARK: - UISearchResultsUpdating

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""

        operationManager.performDelay { [weak self] in
            await self?.viewModel.filter(query: query)
            self?.contentView.scrollToTop(animated: true)
        }
    }
}
