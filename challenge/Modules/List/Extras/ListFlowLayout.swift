//
//  ListFlowLayout.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import UIKit

final class ListFlowLayout: UICollectionViewFlowLayout {
    // MARK: - Properties

    private var cachedItemSize: CGSize?
    private var lastKnownWidth: CGFloat = .zero
    private let aspectRatio: CGFloat

    private let landscapeWidthThreshold: CGFloat = 600

    private var numberOfColumns: Int {
        guard let collectionView = collectionView else {
            return 2
        }

        return collectionView.bounds.width >= landscapeWidthThreshold ? 4 : 2
    }

    // MARK: - Initialization

    init(aspectRatio: CGFloat = 1.4) {
        self.aspectRatio = aspectRatio
        super.init()
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Layout Override

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else {
            return
        }

        let currentWidth = collectionView.bounds.width

        if currentWidth != lastKnownWidth {
            lastKnownWidth = currentWidth
            cachedItemSize = nil
        }

        if cachedItemSize == nil {
            cachedItemSize = calculateItemSize(for: collectionView)
            super.itemSize = cachedItemSize ?? .zero
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }

        let widthChanged = newBounds.width != collectionView.bounds.width

        if widthChanged {
            lastKnownWidth = .zero
            cachedItemSize = nil
        }

        return widthChanged
    }

    // MARK: - Private Methods

    private func setup() {
        minimumInteritemSpacing = Spacing.medium
        minimumLineSpacing = Spacing.medium
        sectionInset = .all(constant: Spacing.medium)
        scrollDirection = .vertical
    }

    private func calculateItemSize(for collectionView: UICollectionView?) -> CGSize {
        guard let collectionView = collectionView else {
            return CGSize(width: 100, height: 130)
        }

        let totalWidth = collectionView.bounds.width
        let horizontalInsets = sectionInset.left + sectionInset.right
        let columns = numberOfColumns
        let totalSpacing = Spacing.medium * CGFloat(columns - 1)
        let availableWidth = totalWidth - horizontalInsets - totalSpacing
        let itemWidth = floor(availableWidth / CGFloat(columns))
        let itemHeight = itemWidth * aspectRatio

        return CGSize(width: itemWidth, height: itemHeight)
    }
}
