//
//  DoubleExtensions.swift
//  challenge
//
//  Created by Wagner Sales on 03/12/25.
//

import Foundation

extension Double {
    var toCurrency: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "R$"

        var formatted = (formatter.string(from: NSNumber(value: self)) ?? "R$ 0,00")
        formatted = formatted.trimmingCharacters(in: .whitespacesAndNewlines)

        // Fixes Brazilian NumberFormatter non-breaking space (U+00A0) to normal space (ASCII 32)
        // for XCTest equality - pt_BR locale inserts \u{00A0} automatically
        formatted = formatted.replacingOccurrences(of: "\u{00A0}", with: " ")

        return formatted
    }
}
