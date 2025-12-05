//
//  KeychainService.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import Foundation
import Security

protocol KeychainServiceProtocol {
    func save(_ data: Data, forKey key: String) throws
    func retrieve(forKey key: String) throws -> Data
    func delete(forKey key: String) throws
    func update(_ data: Data, forKey key: String) throws
}

final class KeychainService: KeychainServiceProtocol {
    // MARK: - Properties

    private let serviceName: String

    // MARK: - Initialization

    init(serviceName: String = AppConfiguration.bundleIdentifier) {
        self.serviceName = serviceName
    }

    // MARK: - KeychainServiceProtocol

    func save(_ data: Data, forKey key: String) throws {
        if exists(forKey: key) {
            try update(data, forKey: key)
            return
        }

        let query = buildQuery(forKey: key)
        var queryWithData = query
        queryWithData[kSecValueData as String] = data

        let status = SecItemAdd(queryWithData as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw mapError(status)
        }
    }

    func retrieve(forKey key: String) throws -> Data {
        var query = buildQuery(forKey: key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw mapError(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        return data
    }

    func delete(forKey key: String) throws {
        let query = buildQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw mapError(status)
        }
    }

    func update(_ data: Data, forKey key: String) throws {
        let query = buildQuery(forKey: key)
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        guard status == errSecSuccess else {
            throw mapError(status)
        }
    }

    func exists(forKey key: String) -> Bool {
        var query = buildQuery(forKey: key)
        query[kSecReturnData as String] = kCFBooleanFalse

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Private Helpers

    private func buildQuery(forKey key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
    }

    private func mapError(_ status: OSStatus) -> KeychainError {
        switch status {
        case errSecItemNotFound:
            return .itemNotFound
        case errSecDuplicateItem:
            return .duplicateItem
        default:
            return .unexpectedStatus(status)
        }
    }
}
