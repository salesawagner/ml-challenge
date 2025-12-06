//
//  LoginView.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import UIKit
import SwiftUI

typealias LoginViewContent = UIView & LoginViewProtocol

protocol LoginViewDelegate: AnyObject {
    func actionButtonTapped()
}

protocol LoginViewProtocol: AnyObject {
    var delegate: LoginViewDelegate? { get set }

    func showLoading()
    func hideLoading()
}

final class LoginView: UIView {
    // MARK: - Properties

    weak var delegate: LoginViewDelegate?

    // MARK: - UI Components

    let actionButton: UIButton = {
        Buttons.create(title: Localized.Button.login)
    }()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Private Methods

    @objc
    func actionButtonTapped() {
        delegate?.actionButtonTapped()
    }
}

// MARK: - ViewCoding

extension LoginView: ViewCoding {
    func configure() {
        backgroundColor = Colors.background
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }

    func buildHierarchy() {
        addSubview(actionButton)
    }

    func buildConstraints() {
        actionButton.center(on: self)
        actionButton.widthAnchor.constraint(equalToConstant: Sizes.quadrupleExtraLarge).isActive = true
    }
}

// MARK: - LoginViewProtocol

extension LoginView: LoginViewProtocol {
    func showLoading() {
        actionButton.configuration?.title = " "
        actionButton.configuration?.showsActivityIndicator = true
    }

    func hideLoading() {
        actionButton.configuration?.title = Localized.Button.login
        actionButton.configuration?.showsActivityIndicator = false
    }
}
