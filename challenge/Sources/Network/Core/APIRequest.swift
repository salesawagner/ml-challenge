//
//  APIRequest.swift
//  API
//
//  Created by Wagner Sales
//

import Foundation

protocol APIRequest: Encodable {
    associatedtype Response: Decodable
    associatedtype ErrorResponse: ErrorResponseProtocol

    var httpMethod: APIHTTPMethod { get }
    var header: [String: String]? { get }
    var resourceName: String { get }
    var serialization: APISerialization { get }
}

extension APIRequest {
    var header: [String: String]? {
        nil
    }

    var serialization: APISerialization {
        httpMethod == .post ? .json : .query
    }

    var toJSON: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        guard
            let data = try? encoder.encode(self),
            !data.isEmpty,
            let jsonString = String(data: data, encoding: .utf8) else {
            return resourceName
        }

        return jsonString
    }

    func getAuthorizationHeader(accessToken: String? = nil) -> [String: String] {
        guard let token = accessToken ?? getSavedToken() else {
            return [:]
        }

        return ["Authorization": "Bearer \(token)"]
    }

    private func getSavedToken() -> String? {
        try? DependencyContainer.shared.tokenManager.retrieveAccessToken()
    }
}
