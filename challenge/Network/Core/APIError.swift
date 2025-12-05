//
//  APIError.swift
//  API
//
//  Created by Wagner Sales
//

import Foundation

enum APIError: Error {
    case badUrl
    case empty
    case invalidResponse
    case invalidParam
    case httpError(statusCode: Int)
    case encodingFailed(Error)
    case decodingFailed(Error, statusCode: Int?)
    case apiError(Any, statusCode: Int)
    case networkError(URLError)
    case unknown(error: Error, statusCode: Int?)
}

extension APIError {
    var statusCode: Int? {
        switch self {
        case .httpError(let statusCode), .apiError(_, let statusCode):
            return statusCode

        case .decodingFailed(_, let statusCode), .unknown(_, let statusCode):
            return statusCode

        default:
            return nil
        }
    }

    var isAuthenticationError: Bool {
        let statusCodeErrors = [400, 401, 403]

        if case .httpError(let statusCode) = self, statusCodeErrors.contains(statusCode) {
            return true
        }

        if case .apiError(_, let statusCode) = self, statusCodeErrors.contains(statusCode) {
            return true
        }

        return false
    }
}
