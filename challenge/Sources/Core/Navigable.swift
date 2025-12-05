//
//  Navigable.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import UIKit

protocol Navigable where Self: UIViewController {
    func navigateToLogin()
}

extension Navigable {
    func navigateToLogin() {
        navigationController?.popToRootViewController(animated: true)
    }
}
