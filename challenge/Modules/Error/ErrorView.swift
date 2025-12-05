//
//  ErrorView.swift
//  challenge
//
//  Created by Wagner Sales on 03/12/25.
//

import UIKit

typealias ErrorViewContent = UIView & ErrorViewProtocol

protocol ErrorViewProtocol {
    var delegate: ErrorViewDelegate? { get set }
    func configure(with displayModel: ErrorViewDisplayModel)
}

protocol ErrorViewDelegate: AnyObject {
    func primaryButtonTapped(action: @escaping () -> Void)
}

final class ErrorView: UIView {
    // MARK: - Properties
    weak var delegate: ErrorViewDelegate?
    private var primaryAction: (() -> Void)?

    // MARK: - UI Components

    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Spacing.large
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Colors.withOpacity(Colors.onSurface, opacity: .high)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = Labels.create(style: .title1)
        label.textAlignment = .center

        return label
    }()

    private let messageLabel: UILabel = {
        let label = Labels.create(style: .body)
        label.textAlignment = .center
        label.textColor = Colors.withOpacity(Colors.onSurface, opacity: .opaque)

        return label
    }()

    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.medium
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private lazy var primaryActionButton: UIButton = {
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
    private func primaryButtonTapped() {
        guard let primaryAction else {
            return
        }

        delegate?.primaryButtonTapped(action: primaryAction)
    }
}

// MARK: - ViewConding

extension ErrorView: ViewCoding {
    func configure() {
        backgroundColor = Colors.background
        primaryActionButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
    }

    func buildHierarchy() {
        addSubview(containerStackView)

        containerStackView.addArrangedSubview(iconImageView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(messageLabel)
        containerStackView.addArrangedSubview(buttonsStackView)

        buttonsStackView.addArrangedSubview(primaryActionButton)
    }

    func buildConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.extraLarge),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.extraLarge)
        ])

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: Sizes.tripleExtraLarge),
            iconImageView.heightAnchor.constraint(equalToConstant: Sizes.tripleExtraLarge)
        ])
    }
}

// MARK: - ErrorViewProtocol

extension ErrorView: ErrorViewProtocol {
    func configure(with displayModel: ErrorViewDisplayModel) {
        iconImageView.image = UIImage(systemName: displayModel.iconName)
        titleLabel.text = displayModel.title

        if let message = displayModel.message {
            messageLabel.text = message
            messageLabel.isHidden = false
        } else {
            messageLabel.isHidden = true
        }

        primaryActionButton.configuration?.title = displayModel.primaryButtonTitle
        primaryAction = displayModel.primaryAction
    }
}
