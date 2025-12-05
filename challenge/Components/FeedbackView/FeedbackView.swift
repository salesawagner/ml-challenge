//
//  FeedbackView.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import UIKit

typealias FeedbackViewContent = UIView & FeedbackViewProtocol

protocol FeedbackViewProtocol: AnyObject {
    var action: (() -> Void)? { get set }
    func configure(with displayModel: FeedbackViewDisplayModel)
}

final class FeedbackView: UIView {
    // MARK: - Properties

    var action: (() -> Void)?

    // MARK: - UI Components

    private let containerStackView: UIStackView = {
        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.alignment = .center
        containerStackView.spacing = Spacing.medium
        containerStackView.translatesAutoresizingMaskIntoConstraints = false

        return containerStackView
    }()

    private let iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = Colors.withOpacity(Colors.onSurface, opacity: .high)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "exclamationmark.triangle")

        return iconImageView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = Labels.create(style: .title2)
        titleLabel.textAlignment = .center

        return titleLabel
    }()

    private let messageLabel: UILabel = {
        let messageLabel = Labels.create(style: .body)
        messageLabel.textAlignment = .center
        messageLabel.textColor = Colors.withOpacity(Colors.onSurface, opacity: .opaque)

        return messageLabel
    }()

    private var actionButton: UIButton = {
        Buttons.create(style: .primary)
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Private Methods

    @objc
    private func actionButtonTapped() {
        action?()
    }
}

// MARK: - ViewCoding

extension FeedbackView: ViewCoding {
    func configure() {
        backgroundColor = Colors.background
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }

    func buildHierarchy() {
        addSubview(containerStackView)

        containerStackView.addArrangedSubview(iconImageView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(messageLabel)
        containerStackView.addArrangedSubview(actionButton)
    }

    func buildConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.large),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.large)
        ])

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: Sizes.extraLarge),
            iconImageView.heightAnchor.constraint(equalToConstant: Sizes.extraLarge)
        ])
    }
}

// MARK: - FeedbackViewProtocol

extension FeedbackView: FeedbackViewProtocol {
    func configure(with displayModel: FeedbackViewDisplayModel) {
        titleLabel.text = displayModel.title

        if let message = displayModel.message {
            messageLabel.text = message
            messageLabel.isHidden = false
        } else {
            messageLabel.isHidden = true
        }

        actionButton.configuration?.title = displayModel.actionButtonTitle
        action = displayModel.action
    }
}
