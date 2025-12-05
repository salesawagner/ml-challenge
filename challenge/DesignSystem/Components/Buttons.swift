//
//  Button.swift
//  challenge
//
//  Created by Wagner Sales
//

import UIKit

struct Buttons {
    enum Style {
        case primary
        case secondary
        case outline
        case destructive

        var backgroundColor: UIColor {
            switch self {
            case .primary: return Colors.primary
            case .secondary: return Colors.secondary
            case .outline: return .clear
            case .destructive: return Colors.error
            }
        }

        var foregroundColor: UIColor {
            switch self {
            case .primary, .destructive: return Colors.onPrimary
            case .secondary: return Colors.onSecondary
            case .outline: return Colors.primary
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .outline: return 1.5
            default: return .zero
            }
        }
    }

    static var defaultConfiguration: UIButton.Configuration {
        UIButton.Configuration.filled()
    }

    static func create(style: Style = .primary, title: String? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.baseBackgroundColor = style.backgroundColor
        config.baseForegroundColor = style.foregroundColor

        // Border
        config.background.strokeColor = style == .outline ? Colors.primary : nil
        config.background.strokeWidth = style.borderWidth

        // Typography
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = Typography.body
            return outgoing
        }

        // 44pt TOUCH TARGET Apple HIG
        config.contentInsets = NSDirectionalEdgeInsets(
            top: Spacing.medium,
            leading: Spacing.large,
            bottom: Spacing.medium,
            trailing: Spacing.large
        )

        button.configuration = config
        button.setTitle(title, for: .normal)
        button.applyShadow(elevation: .level1)
        button.setAppleHIGAutoLayout()

        return button
    }
}

// MARK: - Utilities

extension UIButton {
    func setAppleHIGAutoLayout() {
        // Auto Layout priorities for minimum height 44pt
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)

        // Minimum height(44pt) Constraint (Apple HIG)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: Sizes.extraLarge)
        ])
    }
}
