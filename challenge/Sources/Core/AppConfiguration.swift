//
//  AppConfiguration.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

import Foundation

struct AppConfiguration {
    static let clientId: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "ClientID") as? String, !value.isEmpty else {
            fatalError("❌ ClientID não encontrado no Info.plist")
        }
        return value
    }()

    static let clientSecret: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "ClientSecret") as? String, !value.isEmpty else {
            fatalError("❌ ClientSecret não encontrado no Info.plist")
        }
        return value
    }()

    static let refreshToken: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "RefreshToken") as? String, !value.isEmpty else {
            fatalError("❌ AuthCode não encontrado no Info.plist")
        }
        return value
    }()

    static let redirectURI: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "RedirectURI") as? String, !value.isEmpty else {
            fatalError("❌ RedirectURI não encontrado no Info.plist")
        }
        return value
    }()

    static let apiBaseURL: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String, !value.isEmpty else {
            fatalError("❌ APIBaseURL não encontrado no Info.plist")
        }
        return value
    }()

    static let bundleIdentifier: String = {
        Bundle.main.bundleIdentifier ?? "br.com.wagnersales.challenge"
    }()

    static let searchLimit: Int = {
        20
    }()
}

// MARK: - Uso
extension AppConfiguration {
    static func printConfiguration() {
        let message = """
        \tClient ID: \(clientId)
        \tClient Secret: \(clientSecret.prefix(10))***
        \tRefresh Token: \(refreshToken.prefix(10))***
        \tRedirect URI: \(redirectURI)
        \tAPI Base URL: \(apiBaseURL)
        \tBundle Identifier: \(bundleIdentifier)
        \tSearch Limit: \(searchLimit)
        """

        Logger.log(title: "🔧 App Configuration", message: message, type: .info)
    }
}
