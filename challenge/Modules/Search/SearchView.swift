//
//  SearchView.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import UIKit
import SwiftUI

typealias SearchViewContent = UIView & SearchViewProtocol

protocol SearchViewDelegate: AnyObject {
    func searchView(_ view: SearchView, didSearchFor query: String)
}

protocol SearchViewProtocol: AnyObject {
    var delegate: SearchViewDelegate? { get set }
    func focusSearchField()
    func resignSearchField()
    func clearSearch()
}

final class SearchView: UIView {
    // MARK: - Properties

    private var viewModel: SearchViewModelProtocol?
    weak var delegate: SearchViewDelegate?

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        return scrollView
    }()

    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        return contentView
    }()

    private let inputStackView: UIStackView = {
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = Spacing.small
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        return contentStackView
    }()

    let textField: UITextField = {
        let textField = TextFields.create(style: .search, placeholder: "Buscar produtos")
        textField.autocorrectionType = .no
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing

        return textField
    }()

    var textFieldIconView: UIView = {
        UIView()
    }()

    var textFieldIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = Colors.onBackground
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    let feedbackLabel: UILabel = {
        let label = Labels.create(style: .caption)
        label.textColor = Colors.error

        return label
    }()

    private var scrollViewBottomConstraint: NSLayoutConstraint?
    private var originalBottomConstant: CGFloat = 0

    // MARK: - Initialization

    init(viewModel: SearchViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    deinit {
        removeKeyboardObservers()
    }

    // MARK: - Private Methods

    private func performSearch() {
        guard let query = viewModel?.performSearch() else {
            return
        }

        resignSearchField()
        delegate?.searchView(self, didSearchFor: query)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Actions

    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return
        }

        let newConstant = originalBottomConstant - keyboardFrame.height

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve),
            animations: { [weak self] in
                self?.scrollViewBottomConstraint?.constant = newConstant
                self?.layoutIfNeeded()
            }
        )
    }

    @objc
    private func keyboardWillHide(_ notification: Notification) {
        guard
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return
        }

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve),
            animations: { [weak self] in
                self?.scrollViewBottomConstraint?.constant = self?.originalBottomConstant ?? .zero
                self?.layoutIfNeeded()
            }
        )
    }

    @objc
    private func textFieldDidChange() {
        viewModel?.searchQuery = textField.text
    }

    private func updateFeedback(isShow: Bool) {
        feedbackLabel.text = isShow ? "Necessário 3 characters" : ""
    }
}

// MARK: - ViewCoding

extension SearchView: ViewCoding {
    func configure() {
        backgroundColor = Colors.background
        setupKeyboardObservers()

        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.leftView = textFieldIconView
        textField.leftViewMode = .always
    }

    func buildHierarchy() {
        textFieldIconView.addSubview(textFieldIconImageView)

        inputStackView.addArrangedSubview(textField)
        inputStackView.addArrangedSubview(feedbackLabel)

        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(inputStackView)
    }

    func buildConstraints() {
        contentView.fill(on: scrollView)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        feedbackLabel.heightAnchor.constraint(equalToConstant: Sizes.medium).isActive = true

        NSLayoutConstraint.activate([
            inputStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Sizes.doubleExtraLarge),
            inputStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: Spacing.large),
            inputStackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -Spacing.large),
            inputStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.large)
        ])

        let bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        scrollViewBottomConstraint = bottomConstraint
        originalBottomConstant = bottomConstraint.constant

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomConstraint
        ])

        NSLayoutConstraint.activate([
            textFieldIconImageView.topAnchor.constraint(equalTo: textFieldIconView.topAnchor),
            textFieldIconImageView.leadingAnchor.constraint(equalTo: textFieldIconView.leadingAnchor, constant: Spacing.medium),
            textFieldIconImageView.trailingAnchor.constraint(equalTo: textFieldIconView.trailingAnchor, constant: -Spacing.small),
            textFieldIconImageView.bottomAnchor.constraint(equalTo: textFieldIconView.bottomAnchor)
        ])
    }
}

// MARK: - SearchViewProtocol

extension SearchView: SearchViewProtocol {
    func focusSearchField() {
        textField.becomeFirstResponder()
    }

    func resignSearchField() {
        textField.resignFirstResponder()
    }

    func clearSearch() {
        textField.text = nil
        viewModel?.searchQuery = nil
    }
}

// MARK: - UITextFieldDelegate

extension SearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let isSearchValid = viewModel?.isSearchValid ?? false
        updateFeedback(isShow: !isSearchValid)

        if isSearchValid {
            performSearch()
        }

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersInRanges ranges: [NSValue], replacementString string: String) -> Bool {
        updateFeedback(isShow: false)
        return true
    }
}
