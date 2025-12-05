//
//  KeychainError.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import Foundation

enum KeychainError: LocalizedError {
    case itemNotFound
    case duplicateItem
    case invalidData
    case unexpectedStatus(OSStatus)
    case unableToConvertToData
    case unableToConvertToString
}
