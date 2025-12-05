//
//  ResponseParserProtocol.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

import Foundation

protocol ResponseParserProtocol {
    func parse<R: APIRequest>(_ request: R, data: Data, urlResponse: URLResponse) throws -> R.Response
}

final class ResponseParser: ResponseParserProtocol {
    private let jsonDecoder: JSONDecoder

    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
    }

    func parse<R: APIRequest>(_ request: R, data: Data, urlResponse: URLResponse) throws -> R.Response {
        if urlResponse.url?.scheme == "file" {
            return try parseLocalFile(request, data)
        }

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        return try parseHTTPResponse(request, data: data, httpResponse: httpResponse)
    }

    private func parseLocalFile<R: APIRequest>(_ request: R, _ data: Data) throws -> R.Response {
        #if DEBUG
        logResponseData(request: request, data: data, statusCode: nil)
        #endif

        do {
            let response = try jsonDecoder.decode(R.Response.self, from: data)
            return response
        } catch {
            throw APIError.decodingFailed(error, statusCode: .zero)
        }
    }

    private func decodeResponse<R: APIRequest>(_ request: R,  data: Data, statusCode: Int?) throws -> R.Response {
        do {
            let response = try jsonDecoder.decode(R.Response.self, from: data)
            logResponseData(request: request, data: data, statusCode: nil)

            return response

        } catch {
            Logger.log(
                title: "❌ Decoding Error",
                message: "Request: \(request.toJSON), Error: \(error)",
                type: .error
            )

            throw APIError.decodingFailed(error, statusCode: statusCode)
        }
    }

    private func parseHTTPResponse<R: APIRequest>(
        _ request: R,
        data: Data,
        httpResponse: HTTPURLResponse
    ) throws -> R.Response {
        let statusCode = httpResponse.statusCode

        if (200...299).contains(statusCode) {
            return try decodeResponse(request, data: data, statusCode: statusCode)
        } else {
            throw parseErrorResponse(request, data: data, statusCode: statusCode)
        }
    }

    private func parseErrorResponse<R: APIRequest>(_ request: R,  data: Data, statusCode: Int) -> APIError {
        do {
            let errorResponse = try jsonDecoder.decode(R.ErrorResponse.self, from: data)
            Logger.log(
                title: "📥 API Error \(request.resourceName)",
                message: "request: \(request.toJSON) \n message: \(errorResponse.message)",
                type: .error
            )
            return APIError.apiError(errorResponse, statusCode: statusCode)
        } catch {
            Logger.log(
                title: "📥 HTTP Error: \(request.resourceName)",
                message: "request: \(request.toJSON) \n message: \(error.localizedDescription)",
                type: .error
            )
            return APIError.httpError(statusCode: statusCode)
        }
    }

    #if DEBUG
    private func logResponseData(request: any APIRequest, data: Data, statusCode: Int?, isVerbose: Bool = false) {
        let title = "📥 Response: \(request.resourceName)  statusCode: \(statusCode ?? .zero)"

        if isVerbose {
            Logger.log(title: title, message: data.toJSON)
        } else {
            Logger.log(title: title)
        }
    }
    #endif
}

extension Data {
    var toJSON: String {
        var result: String = "{ }"

        if
            let json = try? JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed),
            let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
            let prettyString = String(data: prettyData, encoding: .utf8)
        {
            result = prettyString
        } else if let rawString = String(data: self, encoding: .utf8) {
            result = rawString
        }

        return result
    }
}
