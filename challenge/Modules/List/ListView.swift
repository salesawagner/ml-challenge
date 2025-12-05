//
//  ListView.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import UIKit

typealias ListViewContent = UIView & ListViewProtocol

protocol ListViewProtocol: AnyObject {
    var delegate: ListViewDelegate? { get set }

    func setItems(_ newItems: [ItemResponse])
    func appendItems(_ newItems: [ItemResponse])
    func showLoading()
    func hideLoading()
    func showEmptyState(with displayModel: EmptyStateViewDisplayModel)
    func clear()
    func scrollToTop(animated: Bool)
}

protocol ListViewDelegate: AnyObject {
    func listCollectionView(_ collectionView: ListView, didSelectItemAt index: Int)
    func listCollectionViewDidReachEnd(_ collectionView: ListView)
}

final class ListView: UIView {
    // MARK: - Properties

    weak var delegate: ListViewDelegate?
    private var items: [ItemResponse] = [] {
        didSet {
            guard !items.isEmpty else {
                return
            }

            collectionView.hideEmptyState()
        }
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
}

// MARK: - ListViewProtocol

extension ListView: ListViewProtocol {
    func setItems(_ newItems: [ItemResponse]) {
        items = newItems
        collectionView.reloadData()
    }

    func appendItems(_ newItems: [ItemResponse]) {
        let startIndex = items.count
        items.append(contentsOf: newItems)

        let indexPaths = (startIndex..<items.count).map { IndexPath(item: $0, section: 0) }
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: indexPaths)
        }
    }

    func showLoading() {
        loadingIndicator.startAnimating()
        collectionView.isHidden = true
    }

    func hideLoading() {
        loadingIndicator.stopAnimating()
        collectionView.isHidden = false
    }

    func showEmptyState(with displayModel: EmptyStateViewDisplayModel) {
        collectionView.showEmptyState(with: displayModel)
    }

    func clear() {
        items.removeAll()
        collectionView.reloadData()
    }

    func scrollToTop(animated: Bool) {
        guard !items.isEmpty else {
            return
        }

        collectionView.scrollToItem(
            at: IndexPath(item: 0, section: 0),
            at: .top,
            animated: animated
        )
    }
}

// MARK: - ViewCoding

extension ListView: ViewCoding {
    func configure() {
        backgroundColor = Colors.background

        collectionView.delegate = self
        collectionView.dataSource = self
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

// MARK: - UICollectionViewDelegate

extension ListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.listCollectionView(self, didSelectItemAt: indexPath.item)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard indexPath.item >= (items.count - 3) else {
            return
        }

        delegate?.listCollectionViewDidReachEnd(self)
    }
}

// MARK: - UICollectionViewDataSource

extension ListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
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

        let item = items[indexPath.item]
        cell.configure(title: item.title, price: item.priceFormatted, imageURL: item.thumbnail)

        return cell
    }
}
