//
//  Typography.swift
//  challenge
//
//  Created by Wagner Sales on 10/12/24.
//

import UIKit

struct Typography {
    private static let metrics = UIFontMetrics(forTextStyle: .body)

    /// Display: Large hero titles (scales with XXXLarge)
    static let display = metrics.scaledFont(for: UIFont.systemFont(ofSize: 34, weight: .bold))

    /// Headline: Section headers (scales with Large Title)
    static let headline = metrics.scaledFont(for: UIFont.systemFont(ofSize: 24, weight: .bold))

    /// Subheadline: Card/list titles (scales with Title 2)
    static let subheadline = metrics.scaledFont(for: UIFont.systemFont(ofSize: 20, weight: .semibold))

    /// Body: Main content text (scales with Body)
    static let body = metrics.scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .regular))

    /// Callout: Labels, metadata (scales with Callout)
    static let callout = metrics.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .regular))

    /// Caption: Helper text (scales with Footnote)
    static let caption = metrics.scaledFont(for: UIFont.systemFont(ofSize: 12, weight: .regular))

    /// Small: Micro text (scales with Caption 1)
    static let small = metrics.scaledFont(for: UIFont.systemFont(ofSize: 10, weight: .regular))
}
