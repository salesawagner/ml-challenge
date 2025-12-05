//
//  StringExtensions.swift
//  challenge
//
//  Created by Wagner Sales
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: .main, value: "", comment: "")
    }
}
