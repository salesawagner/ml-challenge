//
//  FeedbackViewController.swift
//  challenge
//
//  Created by Wagner Sales on 03/12/25.
//

import UIKit

final class FeedbackViewController: UIViewController {
    // MARK: - Properties

    private let displayModel: FeedbackViewDisplayModel
    private var contentView: FeedbackViewContent

    // MARK: - Initialization

    init(feedbackView: FeedbackViewContent = FeedbackView(), displayModel: FeedbackViewDisplayModel) {
        self.contentView = feedbackView
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
        contentView.render(with: displayModel)
        contentView.delegate = self
    }
}

// MARK: - FeedbackViewContentDelegate

extension FeedbackViewController: FeedbackViewContentDelegate {
    func didTapAction() {
        dismiss(animated: true)
    }
}
