//
//  Sizes.swift
//  challenge
//
//  Created by Wagner Sales on 02/12/25.
//

import Foundation

struct Sizes {
    /// 4x scale: Small icons, badges (min touch target aware)
    static let extraSmall: CGFloat = Scale.base * 4

    /// 5x scale: Standard icons, avatars
    static let small: CGFloat = Scale.base * 5

    /// 6x scale: Secondary buttons, thumbnails
    static let medium: CGFloat = Scale.base * 6

    /// 8x scale: Primary buttons, cards
    static let large: CGFloat = Scale.base * 8

    /// 11x scale: Apple HIG minimum touch target (44pt)
    static let extraLarge: CGFloat = Scale.base * 11

    /// 16x scale: Hero images, large avatars
    static let doubleExtraLarge: CGFloat = Scale.base * 16

    /// 24x scale: Large sections, full-width components
    static let tripleExtraLarge: CGFloat = Scale.base * 24

    /// 32x scale: Extra large sections, modals
    static let quadrupleExtraLarge: CGFloat = Scale.base * 32

    /// 40x scale: Hero sections, full-screen components
    static let huge: CGFloat = Scale.base * 40

    /// 48x scale: Maximum content areas, full-screen layouts
    static let superHuge: CGFloat = Scale.base * 48
}
