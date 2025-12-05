//
//  ListCollectionViewCell.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import UIKit

final class ListCollectionViewCell: UICollectionViewCell, ReusableView {
    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.surface
        view.layer.cornerRadius = Corners.lg
        view.applyShadow(elevation: .level2)
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Corners.sm
        imageView.backgroundColor = Colors.placeholder
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = Labels.create(style: .body)
        label.numberOfLines = 2

        return label
    }()

    private let priceLabel: UILabel = {
        let label = Labels.create(style: .body)
        label.textAlignment = .right

        return label
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

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.cancelImageLoading()
        imageView.image = nil
        titleLabel.text = nil
        priceLabel.text = nil
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self else {
                    return
                }

                self.containerView.alpha = self.isHighlighted ? Colors.OpacityLevel.opaque.rawValue : Colors.OpacityLevel.full.rawValue
            }
        }
    }

    // MARK: - Configuration

    func configure(title: String, price: String, imageURL: String? = nil) {
        titleLabel.text = title
        priceLabel.text = price
        imageView.loadImage(from: imageURL)
    }
}

// MARK: - ViewCoding

extension ListCollectionViewCell: ViewCoding {
    func buildHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
    }

    func buildConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.extraSmall),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.extraSmall),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.extraSmall),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.extraSmall)
        ])

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Spacing.small),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Spacing.small),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Spacing.small),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: Scale.sizeMultiplier)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Spacing.small),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Spacing.small),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Spacing.small)
        ])

        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: Spacing.medium),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: Spacing.medium),
            priceLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -Spacing.medium),
            priceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Spacing.medium)
        ])
    }
}
