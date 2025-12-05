//
//  ShadowElevation.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import Foundation

enum ShadowElevation {
    case level1  // Buttons, low cards
    case level2  // Medium cards, search bars

    var opacity: CGFloat {
        switch self {
        case .level1: return 0.08   // 8% - subtle
        case .level2: return 0.12   // 12% - moderate
        }
    }

    var radius: CGFloat {
        switch self {
        case .level1: return 2
        case .level2: return 4
        }
    }

    var offset: CGSize {
        switch self {
        case .level1: return CGSize(width: .zero, height: 1)
        case .level2: return CGSize(width: .zero, height: 2)
        }
    }
}
