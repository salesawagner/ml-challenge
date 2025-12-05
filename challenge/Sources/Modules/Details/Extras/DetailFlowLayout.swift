import UIKit

final class DetailFlowLayout: UICollectionViewFlowLayout {
        // MARK: - Properties

    private var lastKnownBounds: CGRect = .zero

        // MARK: - Initialization

    override init() {
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

        let currentBounds = collectionView.bounds
        guard currentBounds != lastKnownBounds else {
            return
        }

        lastKnownBounds = currentBounds
        let newSize = calculateItemSize(for: collectionView)
        super.itemSize = newSize
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else {
            return false
        }

        let boundsChanged = newBounds.size != collectionView.bounds.size
        if boundsChanged {
            lastKnownBounds = .zero
        }

        return boundsChanged
    }

    override func invalidateLayout() {
        lastKnownBounds = .zero
        super.invalidateLayout()
    }

    // MARK: - Private Methods

    private func setup() {
        minimumInteritemSpacing = .zero
        minimumLineSpacing = .zero
        scrollDirection = .horizontal
        sectionInset = .zero
    }

    private func calculateItemSize(for collectionView: UICollectionView?) -> CGSize {
        guard let collectionView = collectionView else {
            return CGSize(width: 300, height: 400)
        }

        let bounds = collectionView.bounds
        return CGSize(width: bounds.width, height: bounds.height)
    }
}
