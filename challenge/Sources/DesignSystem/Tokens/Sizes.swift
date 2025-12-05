//
//  Sizes.swift
//  challenge
//
//  Created by Wagner Sales on 02/12/25.
//

import Foundation

struct Sizes {
    /// 6x scale: Secondary buttons, thumbnails
    static let medium: CGFloat = Scale.base * 6

    /// 8x scale: Primary buttons, cards
    static let large: CGFloat = Scale.base * 8

    /// 11x scale: Apple HIG minimum touch target (44pt)
    static let extraLarge: CGFloat = Scale.base * 11

    /// 16x scale: Hero images, large avatars
    static let doubleExtraLarge: CGFloat = Scale.base * 16

    /// 32x scale: Extra large sections, modals
    static let quadrupleExtraLarge: CGFloat = Scale.base * 32

    /// 48x scale: Maximum content areas, full-screen layouts
    static let huge: CGFloat = Scale.base * 48

}
