//
//  DetailCollectionViewCell.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import UIKit

final class DetailCollectionViewCell: UICollectionViewCell, ReusableView {
    // MARK: - UI Components

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = Colors.placeholder
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true

        return imageView
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
    }

    // MARK: - Configuration

    func configure(imageURL: String? = nil) {
        imageView.loadImage(from: imageURL)
    }
}

// MARK: - ViewCoding

extension DetailCollectionViewCell: ViewCoding {
    func configure() {
        contentView.backgroundColor = Colors.placeholder
    }

    func buildHierarchy() {
        contentView.addSubview(imageView)
    }

    func buildConstraints() {
        imageView.fill(on: contentView)
    }
}
