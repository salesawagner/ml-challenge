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
        case title1      // Headlines, section titles
        case title2      // Card titles, list headers
        case body        // Main content text
        case caption     // Helper text, metadata
        case button      // Button text (semibold)

        var font: UIFont {
            switch self {
            case .display: return Typography.display
            case .title1: return Typography.headline
            case .title2: return Typography.subheadline
            case .body: return Typography.body
            case .caption: return Typography.caption
            case .button: return UIFont.systemFont(ofSize: 16, weight: .semibold)
            }
        }

        var textColor: UIColor {
            switch self {
            case .button: return Colors.primary
            default: return Colors.onSurface
            }
        }

        var textAlignment: NSTextAlignment {
            switch self {
            case .button: return .center
            default: return .natural
            }
        }
    }

    static func create(style: Style = .body, text: String? = nil) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = style.font
        label.textColor = style.textColor
        label.textAlignment = style.textAlignment
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
