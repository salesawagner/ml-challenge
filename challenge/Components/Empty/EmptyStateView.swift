//
//  EmptyStateView.swift
//  challenge
//
//  Created by Wagner Sales on 03/12/25.
//

import UIKit

typealias EmptyStateViewContent = UIView & EmptyStateViewProtocol

protocol EmptyStateViewProtocol: AnyObject {
    var action: (() -> Void)? { get set }
    func configure(with displayModel: EmptyStateViewDisplayModel)
}

final class EmptyStateView: UIView {
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
        iconImageView.tintColor = Colors.withOpacity(Colors.onSurface, opacity: .ghost)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        return iconImageView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = Labels.create(style: .title2)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = Colors.withOpacity(Colors.onSurface, opacity: .opaque)

        return titleLabel
    }()

    private let messageLabel: UILabel = {
        let messageLabel = Labels.create(style: .body)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = Colors.withOpacity(Colors.onSurface, opacity: .high)

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

extension EmptyStateView: ViewCoding {
    func configure() {
        backgroundColor = .clear
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
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.extraLarge),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.extraLarge)
        ])

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: Sizes.doubleExtraLarge),
            iconImageView.heightAnchor.constraint(equalToConstant: Sizes.doubleExtraLarge)
        ])
    }
}

// MARK: - EmptyStateViewProtocol

extension EmptyStateView: EmptyStateViewProtocol {
    func configure(with displayModel: EmptyStateViewDisplayModel) {
        iconImageView.image = UIImage(systemName: displayModel.iconName)
        titleLabel.text = displayModel.title

        if let message = displayModel.message {
            messageLabel.text = message
            messageLabel.isHidden = false
        } else {
            messageLabel.isHidden = true
        }

        if let actionTitle = displayModel.actionButtonTitle {
            actionButton.configuration?.title = actionTitle
            actionButton.isHidden = false
            action = displayModel.action
        } else {
            actionButton.isHidden = true
        }
    }
}
