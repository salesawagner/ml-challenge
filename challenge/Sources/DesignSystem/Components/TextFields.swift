//
//  TextFields.swift
//  challenge
//
//  Created by Wagner Sales on 10/12/24.
//

import UIKit

struct TextFields {
    enum Style {
        case standard
        case search

        var borderStyle: UITextField.BorderStyle {
            switch self {
            case .search: return .roundedRect
            default: return .none
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .standard: return Colors.surface
            case .search: return .clear
            }
        }

        var borderColor: UIColor { Colors.outline }
        var placeholderColor: UIColor { Colors.placeholder }
    }

    static func create(style: Style = .standard, placeholder: String? = nil) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = style.backgroundColor
        textField.borderStyle = style.borderStyle
        textField.placeholder = placeholder

        // Typography
        textField.font = Typography.body

        textField.setAppleHIGAutoLayout()
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = style == .search ? .search : .done
        textField.autocorrectionType = style == .search ? .no : .yes
        textField.applyShadow(elevation: .level1)

        return textField
    }
}

// MARK: - Helpers

extension UITextField {
    func setAppleHIGAutoLayout() {
        // Minimum height(44pt) Constraint (Apple HIG)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: Sizes.extraLarge)
        ])
    }
}
