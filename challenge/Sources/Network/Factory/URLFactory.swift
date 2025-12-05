//
//  URLBuilderProtocol.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

import Foundation

protocol URLFactoryProtocol {
    func buildURL<T: APIRequest>(for request: T, environment: Environment) throws -> URL?
}

final class URLFactory: URLFactoryProtocol {
    func buildURL<T: APIRequest>(for request: T, environment: Environment) throws -> URL? {
        guard environment.type != .local else {
            guard let localURL = request.localURL else {
                throw APIError.badUrl
            }

            return localURL
        }

        guard
            let domainURL = environment.domainURL,
            let endpoint = URL(string: request.resourceName, relativeTo: domainURL),
            var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true) else {
            Logger.log(
                title: "❌ Invalid URL",
                message: "Domain: \(environment.domainURL?.absoluteString ?? "nil"), Endpoint: \(request.resourceName)",
                type: .error
            )

            throw APIError.badUrl
        }

        if case .query = request.serialization {
            do {
                let queryItems = try URLQueryItemEncoder.encode(request)
                components.queryItems = queryItems
            } catch {
                Logger.log(
                    title: "❌ Query Encoding",
                    message: "Request: \(request.toJSON), Error: \(error)",
                    type: .error
                )

                throw APIError.encodingFailed(error)
            }
        }

        guard let url = components.url else {
            throw APIError.badUrl
        }

        return url
    }
}
