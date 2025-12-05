//
//  APIEnvironmentFactory.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

import Foundation

protocol EnvironmentFactoryProtocol {
    static func createEnvironment(for type: APIEnvironmentType) -> Environment
    static func currentEnvironment() -> Environment
}

struct EnvironmentFactory: EnvironmentFactoryProtocol {
    static func createEnvironment(for type: APIEnvironmentType) -> Environment {
        switch type {
        case .local:
            return LocalEnvironment()

        case .production:
            return ProductionEnvironment()
        }
    }

    static func currentEnvironment() -> Environment {
        #if PRODUCTION
        return createEnvironment(for: .production)
        #else
        return createEnvironment(for: .local)
        #endif
    }
}
