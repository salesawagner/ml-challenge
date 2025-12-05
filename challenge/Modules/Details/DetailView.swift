//
//  DetailView.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import UIKit

typealias DetailViewContent = UIView & DetailViewProtocol

protocol DetailViewProtocol: AnyObject {
    var delegate: DetailViewDelegate? { get set }
    var collectionView: UICollectionView { get }

    func configureItem(with item: ItemResponse)
    func configureDescription(with description: ItemDescriptionResponse)
    func showLoading()
    func hideLoading()
    func showDescriptionError(with displayModel: FeedbackViewDisplayModel)
}

protocol DetailViewDelegate: AnyObject {
    func retryButtonTapped()
}

final class DetailView: UIView {
    // MARK: - Properties

    weak var delegate: DetailViewDelegate?
    private var pictures: [ItemPicture] = [] {
        didSet {
            collectionView.reloadData()
            pageControl.numberOfPages = pictures.count
            pageControl.isHidden = pictures.count <= 1
        }
    }

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never

        return scrollView
    }()

    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = Colors.background

        return contentView
    }()

    var collectionView: UICollectionView = {
        let layout = DetailFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Colors.placeholder
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = .fast

        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }

        return collectionView
    }()

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = Colors.primary
        pageControl.pageIndicatorTintColor = Colors.withOpacity(Colors.onSurface, opacity: .ghost)
        pageControl.hidesForSinglePage = true
        pageControl.isUserInteractionEnabled = false

        return pageControl
    }()

    let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.small
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let titleLabel: UILabel = {
        Labels.create(style: .display)
    }()

    private let priceLabel: UILabel = {
        Labels.create(style: .title2)
    }()

    let descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.large
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let descriptionTitleLabel: UILabel = {
        Labels.create(style: .title2, text: "Descrição") // FIXME:
    }()

    private let descriptionLabel: UILabel = {
        let descriptionLabel = Labels.create(style: .body)
        descriptionLabel.textColor = Colors.withOpacity(Colors.onSurface, opacity: .opaque)
        descriptionLabel.isHidden = true
        descriptionLabel.alpha = .zero

        return descriptionLabel
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        return loadingIndicator
    }()

    private let feedbackView: FeedbackViewContent = {
        let feedbackView = FeedbackView()
        feedbackView.translatesAutoresizingMaskIntoConstraints = false
        feedbackView.isHidden = true
        feedbackView.alpha = .zero

        return feedbackView
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

    private func animateDescriptionLabel(isShow show: Bool) {
        descriptionLabel.isHidden = !show
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.descriptionLabel.alpha = show ? 1 : .zero
        }
    }

    private func animateFeedbackView(isShow show: Bool) {
        feedbackView.isHidden = !show
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.feedbackView.alpha = show ? 1 : .zero
        }
    }
}

// MARK: - ViewCoding

extension DetailView: ViewCoding {
    func configure() {
        backgroundColor = Colors.background

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            DetailCollectionViewCell.self,
            forCellWithReuseIdentifier: DetailCollectionViewCell.reuseIdentifier
        )

        feedbackView.action = { [weak self] in
            self?.delegate?.retryButtonTapped()
        }
    }

    func buildHierarchy() {
        addSubview(loadingIndicator)
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(collectionView)
        contentView.addSubview(pageControl)
        contentView.addSubview(contentStackView)
        contentView.addSubview(descriptionStackView)

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(priceLabel)

        descriptionStackView.addArrangedSubview(descriptionTitleLabel)
        descriptionStackView.addArrangedSubview(loadingIndicator)
        descriptionStackView.addArrangedSubview(descriptionLabel)
        descriptionStackView.addArrangedSubview(feedbackView)
    }

    func buildConstraints() {
        scrollView.fill(on: self)
        contentView.fill(on: scrollView)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        feedbackView.heightAnchor.constraint(greaterThanOrEqualToConstant: Sizes.superHuge).isActive = true

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0 / 3.0)
        ])

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -Spacing.small),
            pageControl.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: Spacing.large),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: Spacing.large),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -Spacing.large)
        ])

        NSLayoutConstraint.activate([
            descriptionStackView.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: Spacing.large),
            descriptionStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: Spacing.large),
            descriptionStackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -Spacing.large),
            descriptionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: - DetailViewProtocol

extension DetailView: DetailViewProtocol {
    func configureItem(with item: ItemResponse) {
        pictures = item.pictures
        titleLabel.text = item.title
        priceLabel.text = item.priceFormatted

        let bottom = safeAreaInsets.bottom + Spacing.medium
        scrollView.contentInset = UIEdgeInsets(top: .zero, left: .zero, bottom: bottom, right: .zero)
    }

    func configureDescription(with description: ItemDescriptionResponse) {
        descriptionLabel.text = description.plainText
    }

    func showLoading() {
        loadingIndicator.startAnimating()
        animateDescriptionLabel(isShow: false)
        animateFeedbackView(isShow: false)
    }

    func hideLoading() {
        loadingIndicator.stopAnimating()
        animateDescriptionLabel(isShow: true)
    }

    func showDescriptionError(with displayModel: FeedbackViewDisplayModel) {
        loadingIndicator.stopAnimating()
        animateDescriptionLabel(isShow: false)

        feedbackView.configure(with: displayModel)
        animateFeedbackView(isShow: true)
    }
}

// MARK: - UICollectionViewDelegate

extension DetailView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = currentPage
    }
}

// MARK: - UICollectionViewDataSource

extension DetailView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pictures.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DetailCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? DetailCollectionViewCell else {
            return UICollectionViewCell()
        }

        let picture = pictures[indexPath.item]
        cell.configure(imageURL: picture.url)

        return cell
    }
}
