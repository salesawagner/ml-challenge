//
//  SearchTextFieldDelegate.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import UIKit

protocol SearchTextFieldDelegate: AnyObject {
    func searchTextFieldDidBeginEditing(_ textField: SearchTextField)
    func searchTextFieldDidEndEditing(_ textField: SearchTextField)
    func searchTextField(_ textField: SearchTextField, didChangeText text: String?)
    func searchTextFieldDidTapReturn(_ textField: SearchTextField)
    func searchTextFieldDidTapCancel(_ textField: SearchTextField)
}

final class SearchTextField: UIView { // FIXME: Remover?
    // MARK: - Properties

    weak var delegate: UITextFieldDelegate? {
        get {
            textField.delegate
        }
        set {
            textField.delegate = newValue
        }
    }

    var text: String? {
        get {
            textField.text
        }
        set {
            textField.text = newValue
        }
    }

    var placeholder: String? {
        get {
            textField.placeholder
        }
        set {
            textField.placeholder = newValue
        }
    }

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = .red

        return view
    }()

    private let searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.backgroundColor = .yellow

        return imageView
    }()

    let textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 17)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .search
        textField.clearButtonMode = .never
        textField.translatesAutoresizingMaskIntoConstraints = false

        textField.backgroundColor = .purple

        return textField
    }()

    private let searchStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    // MARK: - Initialization

    init() { // FIXME: remover?
        super.init(frame: .zero)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Public Methods

    func becomeActive() {
        textField.becomeFirstResponder()
    }

    func resignActive() {
        textField.resignFirstResponder()
    }

    func clear() {
        textField.text = nil
    }
}

// MARK: - ViewCoding

extension SearchTextField: ViewCoding {
    func buildHierarchy() {
//        searchStackView.addArrangedSubview(searchIconImageView)
//        searchStackView.addArrangedSubview(textField)

        addSubview(containerView)
//        containerView.addSubview(searchStackView)
    }

    func buildConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
//
//        containerView.backgroundColor = .yellow

//        NSLayoutConstraint.activate([
//            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
//            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            containerView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: -8),
//            containerView.heightAnchor.constraint(equalToConstant: 44),
//            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
//
//            searchStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
//            searchStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
//            searchStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
//            searchStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
//
//            searchIconImageView.widthAnchor.constraint(equalToConstant: 20),
//            searchIconImageView.heightAnchor.constraint(equalToConstant: 20)
//        ])
    }
}
