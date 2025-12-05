//
//  Corners.swift
//  challenge
//
//  Created by Wagner Sales on 03/12/25.
//

import Foundation

struct Corners {
    // MARK: - No radius

    /// 0x scale: No rounding
    static let none: CGFloat = 0

    /// 1x scale: Very subtle, minimal rounding
    static let xs: CGFloat = Scale.base * 1

    /// 2x scale: Small buttons, badges, subtle elements
    static let sm: CGFloat = Scale.base * 2

    /// 3x scale: Default radius, basic components
    static let base: CGFloat = Scale.base * 3

    /// 4x scale: Standard medium radius, general purpose
    static let md: CGFloat = Scale.base * 4

    /// 6x scale: Larger components, cards with content
    static let lg: CGFloat = Scale.base * 6

    /// 8x scale: Extra large, prominent UI elements
    static let xl: CGFloat = Scale.base * 8
}
