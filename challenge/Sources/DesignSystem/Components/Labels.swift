//
//  Labels.swift
//  challenge
//
//  Created by Wagner Sales on 02/12/25.
//

import UIKit

struct Labels {
    enum Style {
        case display      // Title
        case title2      // Card titles, list headers
        case body        // Main content text
        case caption     // Helper text, metadata

        var font: UIFont {
            switch self {
            case .display: return Typography.display
            case .title2: return Typography.subheadline
            case .body: return Typography.body
            case .caption: return Typography.caption
            }
        }
    }

    static func create(style: Style = .body, text: String? = nil) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = style.font
        label.textColor = Colors.onSurface
        label.textAlignment = .natural
        label.numberOfLines = .zero
        label.adjustsFontForContentSizeCategory = true

        // Line height
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Spacing.small
        paragraphStyle.lineHeightMultiple = 1.2

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle
        ]

        label.attributedText = NSAttributedString(
            string: label.text ?? "",
            attributes: attributes
        )

        return label
    }
}
