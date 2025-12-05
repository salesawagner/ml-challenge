//
//  ListViewController.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import UIKit

final class ListViewController: UIViewController {
    // MARK: - Properties

    private var viewModel: ListViewModelProtocol
    private let contentView: ListViewContent
    private let listDebouncer = Debouncer()
    private let searchDebouncer = Debouncer(delay: .milliseconds(300))

    private var query: String {
        viewModel.query
    }

    private let searchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Buscar produtos" // FIXME:

        return searchController
    }()

    // MARK: - Initialization

    init(viewModel: ListViewModelProtocol, contentView: ListViewContent = ListView()) {
        self.viewModel = viewModel
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)

        setupViewModel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    deinit {
        listDebouncer.cancel()
        searchDebouncer.cancel()
        viewModel.didChangeState = nil
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupSearchController()

        listDebouncer.debounce { [weak self] in
            await self?.viewModel.viewDidLoad()
        }
    }

    // MARK: - Setups

    private func setupViewModel() {
        viewModel.didChangeState = { [weak self] state in
            self?.handleStateChange(state)
        }
    }

    private func setupViewController() {
        title = "Produtos"
        contentView.delegate = self
    }

    private func setupSearchController() {
        searchController.searchBar.text = query
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar produtos"

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true
    }

    // MARK: - Private Methods

    private func fetch(query: String? = nil) {
        contentView.scrollToTop(animated: true)
        listDebouncer.debounce { [weak self] in
            await self?.viewModel.filter(query: query ?? "")
        }
    }

    private func clearSearch() {
        searchController.searchBar.text = ""
        searchController.searchBar.resignFirstResponder()
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
            handleAppendState(items)

        case .failure(let displayModel):
            handleFailureState(displayModel: displayModel)

        case .unauthorized:
            handleUnauthorized()

        case .refresh:
            handleRefresh()

        case .retry:
            handleRetry()
        }
    }

    private func handleIdleState() {
        contentView.hideLoading()
    }

    private func handleLoadingState() {
        contentView.showLoading()
    }

    private func handleEmptyState(displayModel: EmptyStateViewDisplayModel) {
        contentView.setItems([])
        contentView.showEmptyState(with: displayModel)
        contentView.hideLoading()
    }

    private func handleSuccessState(_ items: [ItemResponse]) {
        contentView.setItems(items)
        contentView.hideLoading()
    }

    private func handleAppendState(_ items: [ItemResponse]) {
        contentView.appendItems(items)
        contentView.hideLoading()
    }

    private func handleFailureState(displayModel: ErrorViewDisplayModel) {
        contentView.hideLoading()

        let errorViewController = ErrorViewController(displayModel: displayModel)
        present(errorViewController, animated: true)
    }

    private func handleUnauthorized() {
        navigationController?.popToRootViewController(animated: true)
    }

    private func handleRefresh() {
        clearSearch()
    }

    private func handleRetry() {
        fetch(query: viewModel.query)
    }
}

// MARK: - ListViewDelegate

extension ListViewController: ListViewDelegate {
    func listCollectionView(_ collectionView: ListView, didSelectItemAt index: Int) {
        guard let itemResponse = viewModel.getItem(at: index) else {
            return
        }

        let detailViewModel = DetailViewModel(itemResponse: itemResponse)
        let detailViewController = DetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func listCollectionViewDidReachEnd(_ collectionView: ListView) {
        listDebouncer.debounce { [weak self] in
            await self?.viewModel.paginate()
        }
    }
}

// MARK: - UISearchResultsUpdating

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        searchDebouncer.debounce { [weak self] in
            await self?.viewModel.filter(query: query)
        }
    }
}
