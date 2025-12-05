//
//  AppColors.swift
//  challenge
//
//  Created by Wagner Sales on 10/12/24.
//

import UIKit

struct Colors {
    // MARK: - Semantic Colors

    /// Primary action color - Main CTAs, buttons, accents
    static let primary = UIColor(named: "PrimaryColor") ?? UIColor.systemBlue

    /// Main backgrounds - Screens, main containers
    static let background = UIColor(named: "BackgroundColor") ?? UIColor.systemBackground

    /// Elevated surfaces - Cards, sheets, modals
    static let surface = UIColor(named: "SurfaceColor") ?? UIColor.systemGroupedBackground

    /// Errors & destructive actions
    static let error = UIColor(named: "ErrorColor") ?? UIColor.systemRed

    // MARK: - OnSurface Colors

    /// Text/icons on primary backgrounds
    static let onPrimary = UIColor(named: "OnPrimaryColor") ?? UIColor.white

    /// Main content text/icons
    static let onBackground = UIColor(named: "OnBackgroundColor") ?? UIColor.label

    /// Text/icons on surface backgrounds
    static let onSurface = UIColor(named: "OnSurfaceColor") ?? UIColor.label

    // MARK: - Neutral Colors

    /// Input placeholders, disabled states
    static let placeholder = UIColor(named: "PlaceholderColor") ?? UIColor.placeholderText

    /// Subtle borders, dividers
    static let outline = UIColor(named: "OutlineColor") ?? UIColor.separator

    /// Shadow color for elevated surfaces
    static let shadow = UIColor(named: "ShadowColor") ?? UIColor.black
}

// MARK: Color Opacity

extension Colors {
    enum OpacityLevel: CGFloat {
        /// Almost invisible - 4%
        case ghost = 0.04

        /// High visibility - 54%
        case high = 0.54

        /// Almost opaque - 87%
        case opaque = 0.87

        /// Fully opaque - 100%
        case full = 1.0
    }
}

// MARK: - Color Utilities

extension Colors {
    static func shadowColor(elevation: ShadowElevation) -> UIColor {
        shadow.withAlphaComponent(elevation.opacity)
    }

    static func withOpacity(_ color: UIColor, opacity: OpacityLevel) -> UIColor {
        return color.withAlphaComponent(opacity.rawValue)
    }
}
