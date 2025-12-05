//
//  Button.swift
//  challenge
//
//  Created by Wagner Sales
//

import UIKit

struct Buttons {
    static var defaultConfiguration: UIButton.Configuration {
        UIButton.Configuration.filled()
    }

    static func create(title: String? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.baseBackgroundColor = Colors.primary
        config.baseForegroundColor = Colors.onPrimary

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
