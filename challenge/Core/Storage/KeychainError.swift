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

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Item não encontrado no Keychain" // FIXME:

        case .duplicateItem:
            return "Item já existe no Keychain"

        case .invalidData:
            return "Dados inválidos"

        case .unexpectedStatus(let status):
            return "Status inesperado do Keychain: \(status)"

        case .unableToConvertToData:
            return "Não foi possível converter para Data"

        case .unableToConvertToString:
            return "Não foi possível converter para String"
        }
    }
}
