//
//  ErrorViewController.swift
//  challenge
//
//  Created by Wagner Sales on 03/12/25.
//

import UIKit

final class ErrorViewController: UIViewController {
    // MARK: - Properties

    private let displayModel: ErrorViewDisplayModel
    private var contentView: ErrorViewContent

    // MARK: - Initialization

    init(errorView: ErrorViewContent = ErrorView(), displayModel: ErrorViewDisplayModel) {
        self.contentView = errorView
        self.displayModel = displayModel
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        contentView.delegate = self
        contentView.configure(with: displayModel)
    }
}

extension ErrorViewController: ErrorViewDelegate {
    func primaryButtonTapped(action: @escaping () -> Void) {
        dismiss(animated: true) {
            action()
        }
    }
}
