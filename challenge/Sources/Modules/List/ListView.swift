//
//  ListView.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import UIKit

protocol ListViewDelegate: AnyObject {
    func listViewDidSelectItem(at index: Int)
    func listViewDidReachEnd()
}

protocol ListDataRenderable: AnyObject {
    func renderItems(_ items: [ListItemDisplayModel])
    func appendItems(_ items: [ListItemDisplayModel])
    func clearItems()
}

protocol ListViewDataSource: AnyObject {
    var numberOfItems: Int { get }
    func item(at index: Int) -> ListItemDisplayModel?
}

protocol ListViewConfigurable {
    var delegate: ListViewDelegate? { get set }
    var dataSource: ListViewDataSource? { get set }
}

typealias ListViewProtocol = Loadable & FeedbackViewShowable & ScrollableToTop & ListDataRenderable & ListViewConfigurable
typealias ListViewContent = UIView & ListViewProtocol

final class ListView: UIView, ListViewConfigurable {
    // MARK: - Properties

    weak var delegate: ListViewDelegate?
    weak var dataSource: ListViewDataSource?
    private var cachedItemCount: Int = 0

    /// Triggers pagination when there are 3 items left until the end.
    private var paginationThreshold: Int {
        3
    }

    // MARK: - UI Components

    let collectionView: UICollectionView = {
        let layout = ListFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Colors.background
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        return loadingIndicator
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

    private func shouldTriggerPagination(for indexPath: IndexPath) -> Bool {
        indexPath.item >= (cachedItemCount - paginationThreshold)
    }
}

// MARK: - ViewCoding

extension ListView: ViewCoding {
    func configure() {
        backgroundColor = Colors.background

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(
            ListCollectionViewCell.self,
            forCellWithReuseIdentifier: ListCollectionViewCell.reuseIdentifier
        )
    }

    func buildHierarchy() {
        addSubview(collectionView)
        addSubview(loadingIndicator)
    }

    func buildConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        loadingIndicator.center(on: self)
    }
}

// MARK: - Loadable Protocol

extension ListView: Loadable {
    func showLoading() {
        loadingIndicator.startAnimating()
        collectionView.isHidden = true
    }

    func hideLoading() {
        loadingIndicator.stopAnimating()
        collectionView.isHidden = false
    }
}

// MARK: - FeedbackViewShowable Protocol

extension ListView: FeedbackViewShowable {
    func showEmptyState(with displayModel: FeedbackViewDisplayModel) {
        collectionView.showEmptyState(with: displayModel)
    }

    func hideEmptyState() {
        collectionView.hideEmptyState()
    }
}

// MARK: - ScrollableToTop Protocol

extension ListView: ScrollableToTop {
    func scrollToTop(animated: Bool) {
        guard cachedItemCount > 0 else {
            return
        }

        collectionView.scrollToItem(
            at: IndexPath(item: 0, section: 0),
            at: .top,
            animated: animated
        )
    }
}

// MARK: - ListDataRenderable Protocol

extension ListView: ListDataRenderable {
    func renderItems(_ items: [ListItemDisplayModel]) {
        cachedItemCount = items.count
        collectionView.reloadData()

        if !items.isEmpty {
            hideEmptyState()
        }
    }

    func appendItems(_ items: [ListItemDisplayModel]) {
        let startIndex = cachedItemCount
        cachedItemCount += items.count

        let indexPaths = (startIndex..<cachedItemCount).map {
            IndexPath(item: $0, section: 0)
        }

        collectionView.performBatchUpdates {
            collectionView.insertItems(at: indexPaths)
        } completion: { [weak self] finished in
            if !finished {
                self?.collectionView.reloadData()
            }
        }
    }

    func clearItems() {
        cachedItemCount = 0
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate

extension ListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.listViewDidSelectItem(at: indexPath.item)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard shouldTriggerPagination(for: indexPath) else {
            return
        }

        delegate?.listViewDidReachEnd()
    }
}

// MARK: - UICollectionViewDataSource

extension ListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cachedItemCount
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ListCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? ListCollectionViewCell else {
            return UICollectionViewCell()
        }

        if let item = dataSource?.item(at: indexPath.item) {
            cell.configure(displayModel: item)
        }

        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension ListView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if shouldTriggerPagination(for: indexPath) {
                delegate?.listViewDidReachEnd()
                break
            }
        }
    }
}
