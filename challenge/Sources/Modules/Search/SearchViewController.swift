//
//  SearchViewController.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import UIKit

final class SearchViewController: UIViewController {
    // MARK: - Properties

    private var viewModel: SearchViewModelProtocol
    private let contentView: SearchViewContent

    // MARK: - Initialization

    init(viewModel: SearchViewModelProtocol, contentView: SearchViewContent? = nil) {
        self.viewModel = viewModel
        self.contentView = contentView ?? SearchView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
        setups()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = contentView
        contentView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.focusSearchField()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentView.resignSearchField()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    // MARK: - Private Methods

    private func setups() {
        setupNavigation()
        setupView()
    }

    private func setupNavigation() {
        navigationItem.hidesBackButton = true
    }

    private func setupView() {
        title = Localized.Search.title
    }
}

// MARK: - SearchViewDelegate

extension SearchViewController: SearchViewDelegate {
    func searchView(_ view: SearchView, didSearchFor query: String) {
        let viewModel = ListViewModel(userId: viewModel.userId, query: query)
        let viewController = ListViewController(viewModel: viewModel)

        navigationController?.pushViewController(viewController, animated: true)
    }
}
