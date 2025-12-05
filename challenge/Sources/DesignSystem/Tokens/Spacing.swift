//
//  AppSpacing.swift
//  challenge
//
//  Created by Wagner Sales on 10/12/24.
//

import UIKit

struct Spacing {
    /// 1x scale: Micro spacing for tight layouts
    static let extraSmall: CGFloat = Scale.base * 1

    /// 2x scale: Default element spacing
    static let small: CGFloat = Scale.base * 2

    /// 4x scale: Standard paragraph/line spacing
    static let medium: CGFloat = Scale.base * 4

    /// 6x scale: Component padding, card margins
    static let large: CGFloat = Scale.base * 6

    /// 8x scale: Section spacing, group dividers
    static let extraLarge: CGFloat = Scale.base * 8

    /// 16x scale: Page/screen major sections
    static let doubleExtraLarge: CGFloat = Scale.base * 16
}
