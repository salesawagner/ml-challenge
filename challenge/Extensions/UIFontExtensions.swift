//
//  UIFontExtension.swift
//  challenge
//
//  Created by Wagner Sales
//

import UIKit

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [
            UIFontDescriptor.TraitKey.weight: weight
        ]])

        return UIFont(descriptor: newDescriptor, size: pointSize)
    }

    var bold: UIFont {
        withWeight(.bold)
    }

    var semibold: UIFont {
        withWeight(.semibold)
    }
}
