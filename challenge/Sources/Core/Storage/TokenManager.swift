//
//  TokenStorage.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import Foundation

protocol TokenStorageProtocol {
    func clear() throws
    func hasRefreshToken() -> Bool
    func isValidToken() -> Bool
    func retrieveAccessToken() throws -> String
    func retrieveToken() throws -> TokenResponse
    func retrieveRefreshToken() throws -> String
    func retrieveUserId() throws -> Int
    func saveRefreshToken(_ refreshToken: String) throws
    func saveToken(_ token: TokenResponse) throws
}

extension TokenStorageProtocol {
    func printConfiguration() {
        var message: String = ""
        message += "\tisValidToken: \(isValidToken())\n"

        do {
            let refresgToken = try retrieveRefreshToken()
            message += "\trefresgToken: \(refresgToken.prefix(20))... \n"

            let tokenResponse = try retrieveToken()
            message += "\tAccess: \(tokenResponse.accessToken)...\n"
            message += "\tRefresh: \(tokenResponse.refreshToken.prefix(20))...\n"
            message += "\tUser ID: \(tokenResponse.userId)"
        } catch {
            message += "\t❌ Token Response não disponíveis: \(error.localizedDescription)\n"
        }

        Logger.log(title: "🔐 Token Manager Status", message: message, type: .info)
    }
}

final class TokenManager {
    // MARK: - Properties

    private let environment: Environment
    private let keychainService: KeychainServiceProtocol
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private enum Keys {
        static let expirationDate = "auth.expiration_date"
        static let tokenResponse = "auth.token_response"
        static let refreshToken = "auth.refresh_token"
    }

    // MARK: - Initialization

    init(
        environment: Environment,
        keychainService: KeychainServiceProtocol = KeychainService(),
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.environment = environment
        self.keychainService = keychainService
        self.encoder = encoder
        self.decoder = decoder
    }

    // MARK: - Private Methods

    private func retrieveExpirationDate() throws -> Date {
        let data = try keychainService.retrieve(forKey: Keys.expirationDate)

        let timestamp = data.withUnsafeBytes {
            $0.load(as: TimeInterval.self)
        }

        return Date(timeIntervalSinceReferenceDate: timestamp)
    }

    private func saveExpirationDate(_ expiresIn: Int) throws {
        let expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))

        let timestamp = expirationDate.timeIntervalSinceReferenceDate
        let data = withUnsafeBytes(of: timestamp) {
            Data($0)
        }

        try keychainService.save(data, forKey: Keys.expirationDate)
    }
}

// MARK: - TokenStorageProtocol

extension TokenManager: TokenStorageProtocol {
    func clear() throws {
        Logger.log(title: "❌ TokenManager", message: "Tokens apagados!", type: .fault)
        try keychainService.delete(forKey: Keys.refreshToken)
        try keychainService.delete(forKey: Keys.tokenResponse)
        try keychainService.delete(forKey: Keys.expirationDate)
    }

    func hasRefreshToken() -> Bool {
        guard let _ = try? retrieveRefreshToken() else {
            return false
        }

        return true
    }

    func isValidToken() -> Bool {
        guard let expirationDate = try? retrieveExpirationDate() else {
            return false
        }

        return expirationDate > Date()
    }

    func retrieveAccessToken() throws -> String {
        try retrieveToken().accessToken
    }

    func retrieveToken() throws -> TokenResponse {
        let data = try keychainService.retrieve(forKey: Keys.tokenResponse)

        guard let token = try? decoder.decode(TokenResponse.self, from: data) else {
            throw KeychainError.invalidData
        }

        return token
    }

    func retrieveRefreshToken() throws -> String {
        let data = try keychainService.retrieve(forKey: Keys.refreshToken)

        guard let refreshToken = try? decoder.decode(String.self, from: data) else {
            throw KeychainError.invalidData
        }

        return refreshToken
    }

    func saveRefreshToken(_ refreshToken: String) throws {
        guard environment.type != .local else {
            return
        }

        guard let data = try? encoder.encode(refreshToken) else {
            throw KeychainError.unableToConvertToData
        }

        try keychainService.save(data, forKey: Keys.refreshToken)
    }

    func retrieveUserId() throws -> Int {
        try retrieveToken().userId
    }

    func saveToken(_ tokenResponse: TokenResponse) throws {
        guard environment.type != .local else {
            return
        }

        guard let data = try? encoder.encode(tokenResponse) else {
            throw KeychainError.unableToConvertToData
        }

        try keychainService.save(data, forKey: Keys.tokenResponse)
        try saveExpirationDate(tokenResponse.expiresIn)
        try saveRefreshToken(tokenResponse.refreshToken)
    }
}
