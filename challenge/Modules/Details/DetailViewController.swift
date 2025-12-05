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
    private let contentView: DetailViewContent
    private var currentTask: Task<Void, Never>?
    private var currentPage: Int = .zero

    // MARK: - Initialization

    init(viewModel: DetailViewModelProtocol, contentView: DetailViewContent = DetailView()) {
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
        currentTask?.cancel()
        viewModel.didChangeState = nil
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        currentTask = Task {
            await viewModel.viewDidLoad()
        }
    }

    // MARK: - Setups

    private func setupViewModel() {
        viewModel.didChangeState = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleStateChange(state)
            }
        }
    }

    private func setupContentView() {
        contentView.delegate = self
    }
}

// MARK: - Handlers

extension DetailViewController {
    private func handleStateChange(_ state: DetailState) {
        switch state {
        case .idle:
            handleIdleState()

        case .displayingItem(let item):
            handleInitializing(item)

        case .loading:
            handleLoadingState()

        case .success(let item):
            handleSuccessState(item)

        case .failure:
            handleFailureState()

        case .unauthorized:
            handleUnauthorized()

        case .descriptionError(displayModel: let displayModel):
            handleDescriptionErrorState(displayModel)
        }
    }

    private func handleIdleState() {
        contentView.hideLoading()
    }

    private func handleInitializing(_ item: ItemResponse) {
        contentView.configureItem(with: item)
    }

    private func handleLoadingState() {
        contentView.showLoading()
    }

    private func handleSuccessState(_ description: ItemDescriptionResponse) {
        contentView.configureDescription(with: description)
        contentView.hideLoading()
    }

    private func handleFailureState() {
        navigationController?.popToRootViewController(animated: true)
    }

    private func handleDescriptionErrorState(_ displayModel: FeedbackViewDisplayModel) {
        contentView.showDescriptionError(with: displayModel)
    }

    private func handleUnauthorized() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - DetailViewDelegate

extension DetailViewController: DetailViewDelegate {
    func retryButtonTapped() {
        currentTask = Task {
            await viewModel.fetchDescription()
        }
    }
}
