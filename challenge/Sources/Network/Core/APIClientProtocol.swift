//
//  APIClient.swift
//  API
//
//  Created by Wagner Sales
//

import Foundation

typealias ResultCallback<Value> = (Result<Value, APIError>) -> Void
protocol APIClientProtocol {
    func send<R: APIRequest>(_ request: R) async throws -> R.Response
}
