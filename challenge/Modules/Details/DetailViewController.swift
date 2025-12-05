//
//  DetailViewController.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import UIKit

final class DetailViewController: UIViewController {
    // MARK: - Properties

    private var viewModel: DetailViewModelProtocol
    private var contentView: DetailViewContent
    private let operationManager: OperationManager

    // MARK: - Initialization

    init(
        viewModel: DetailViewModelProtocol,
        contentView: DetailViewContent = DetailView(),
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
        viewModel.didChangeContentState = nil
        viewModel.didChangeDescriptionState = nil
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        performInitialLoad()
    }

    private func performInitialLoad() {
        operationManager.performImmediate { [weak self] in
            await self?.viewModel.viewDidLoad()
        }
    }

    // MARK: - Setups

    private func setupViewModel() {
        viewModel.didChangeContentState = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleContentStateChange(state)
            }
        }

        viewModel.didChangeDescriptionState = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleDescriptionStateChange(state)
            }
        }
    }
}

// MARK: - Content Handlers

extension DetailViewController {
    private func handleContentStateChange(_ state: DetailContentState) {
        switch state {
        case .idle:
            handleIdleState()

        case .displayingItem(let item):
            handleDisplayItem(item)
        }
    }

    private func handleIdleState() {
        contentView.hideLoading()
    }

    private func handleDisplayItem(_ item: ItemResponse) {
        let displayModel = DetailViewDisplayModel.from(item)
        contentView.renderContentItem(displayModel)
    }
}

// MARK: - Handlers

extension DetailViewController {
    private func handleDescriptionStateChange(_ state: DetailDescriptionState) {
        switch state {
        case .idle:
            handleIdleState()

        case .loading:
            handleLoadingState()

        case .success(let description):
            handleSuccessState(description)

        case .unauthorized:
            handleUnauthorizedState()

        case .descriptionError(let displayModel):
            handleDescriptionErrorState(displayModel)

        case .retry:
            handleRetryState()
        }
    }

    private func handleLoadingState() {
        contentView.showLoading()
    }

    private func handleSuccessState(_ description: ItemDescriptionResponse) {
        contentView.renderDescriptionItem(description.plainText)
        contentView.hideLoading()
    }

    private func handleDescriptionErrorState(_ displayModel: FeedbackViewDisplayModel) {
        contentView.showEmptyState(with: displayModel)
        contentView.hideLoading()
    }

    private func handleUnauthorizedState() {
        navigationController?.popToRootViewController(animated: true)
    }

    private func handleRetryState() {
        operationManager.performImmediate { [weak self] in
            await self?.viewModel.fetchDescription()
        }
    }
}
