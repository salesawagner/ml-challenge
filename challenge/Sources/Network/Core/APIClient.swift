//
//  APIClient.swift
//  API
//
//  Created by Wagner Sales
//

import Foundation

final class APIClient {
    // MARK: Private Properties

    private let environment: Environment
    private let session: URLSession
    private let urlFactory: URLFactoryProtocol
    private let requestFactory: RequestFactoryProtocol
    private let responseParser: ResponseParserProtocol

    // MARK: Inits

    init(
        environment: Environment,
        session: URLSession = .shared,
        urlBuilder: URLFactoryProtocol = URLFactory(),
        requestBuilder: RequestFactoryProtocol = RequestFactory(),
        responseParser: ResponseParserProtocol = ResponseParser()
    ) {
        self.environment = environment
        self.session = session
        self.urlFactory = urlBuilder
        self.requestFactory = requestBuilder
        self.responseParser = responseParser
    }
}

// MARK: APIClient

extension APIClient: APIClientProtocol {
    func send<R: APIRequest>(_ request: R) async throws -> R.Response {
        do {
            guard let url = try urlFactory.buildURL(for: request, environment: environment) else {
                throw APIError.badUrl
            }

            let urlRequest = try requestFactory.build(request, url: url)
            let (data, response) = try await session.data(for: urlRequest)

            return try responseParser.parse(request, data: data, urlResponse: response)

        } catch APIError.badUrl {
            Logger.log(
                title: "🌐 Send Network Error APIError.badUrl",
                message: "Request: \(request.toJSON)",
                type: .error
            )
            throw APIError.badUrl

        } catch let urlError as URLError {
            Logger.log(
                title: "🌐 Send Network Error urlError",
                message: "urlError: \(urlError.localizedDescription) \n Request: \(request.toJSON)",
                type: .error
            )
            throw APIError.networkError(urlError)

        } catch let apiError as APIError {
            Logger.log(
                title: "🌐 Send Network Error apiError",
                message: "apiError: \(apiError.localizedDescription) \n Request: \(request.toJSON)",
                type: .error
            )
            throw apiError

        } catch {
            Logger.log(
                title: "🌐 Send Network Error unknown",
                message: "error: \(error.localizedDescription) \n Request: \(request.toJSON)",
                type: .error
            )
            throw APIError.unknown(error: error, statusCode: 0)
        }
    }
}
