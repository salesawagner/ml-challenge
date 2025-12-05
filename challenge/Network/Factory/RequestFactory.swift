//
//  RequestFactory.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

import Foundation

protocol RequestFactoryProtocol {
    func build<R: APIRequest>(_ request: R, url: URL) throws -> URLRequest
}

final class RequestFactory: RequestFactoryProtocol {
    private let jsonEncoder: JSONEncoder

    init(jsonEncoder: JSONEncoder = JSONEncoder()) {
        self.jsonEncoder = jsonEncoder
    }

    func build<R: APIRequest>(_ request: R, url: URL) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")

        request.header?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        do {
            switch request.serialization {
            case .json:
                let parameters = try jsonEncoder.encode(request)
                urlRequest.httpBody = parameters
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            case .formUrlEncoded(let parameters):
                urlRequest.httpBody = formUrlEncodedBody(from: parameters)
                urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            case .query:
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            Logger.log(
                title: "📤 API Request: \(request.resourceName)",
                message: urlRequest.cURL(pretty: true)
            )
            return urlRequest

        } catch {
            Logger.log(
                title: "📤 API Request: \(request.resourceName)",
                message: "Request: \(request.toJSON), \n Error: \(error.localizedDescription)",
                type: .error
            )

            throw APIError.invalidParam
        }
    }

    private func formUrlEncodedBody(from parameters: [String: String]) -> Data {
        let parameterArray = parameters.map { key, value in
            let percentEscapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let percentEscapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value

            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }

        return parameterArray.joined(separator: "&").data(using: .utf8)!
    }
}
