//
//  MockTokenManager.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import Foundation
@testable import challenge

final class MockTokenManager: Spy<MockTokenManager.Message> {
    enum Message {
        case clear
        case saveRefreshToken
        case saveToken
    }

    // MARK: - Properties

    var hasRefreshTokenResult = false
    var isValidTokenResult = false
    var retrieveAccessTokenResult: Result<String, Error> = .failure(KeychainError.itemNotFound)
    var retrieveTokenResult: Result<TokenResponse, Error> = .failure(KeychainError.itemNotFound)
    var retrieveRefreshTokenResult: Result<String, Error> = .failure(KeychainError.itemNotFound)
    var retrieveUserIdResult: Result<Int, Error> = .failure(KeychainError.itemNotFound)
    var savedToken: TokenResponse?
}

// MARK: - MockResetable

extension MockTokenManager: MockResetable {
    func resetMock() {
        hasRefreshTokenResult = false
        isValidTokenResult = false
        retrieveAccessTokenResult = .failure(KeychainError.itemNotFound)
        retrieveTokenResult = .failure(KeychainError.itemNotFound)
        retrieveRefreshTokenResult = .failure(KeychainError.itemNotFound)
        retrieveUserIdResult = .failure(KeychainError.itemNotFound)
        savedToken = nil
    }
}

// MARK: - TokenStorageProtocol

extension MockTokenManager: TokenStorageProtocol {
    func clear() throws {
        record(.clear)
    }

    func hasRefreshToken() -> Bool {
        hasRefreshTokenResult
    }

    func isValidToken() -> Bool {
        isValidTokenResult
    }

    func retrieveAccessToken() throws -> String {
        try retrieveAccessTokenResult.get()
    }

    func retrieveToken() throws -> TokenResponse {
        try retrieveTokenResult.get()
    }

    func retrieveRefreshToken() throws -> String {
        try retrieveRefreshTokenResult.get()
    }

    func retrieveUserId() throws -> Int {
        try retrieveUserIdResult.get()
    }

    func saveRefreshToken(_ refreshToken: String) throws {
        record(.saveRefreshToken)
    }

    func saveToken(_ token: TokenResponse) throws {
        record(.saveToken)
        savedToken = token
    }
}
