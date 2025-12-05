//
//  WASAPIMock.swift
//  challengeTests
//
//  Created by Wagner Sales
//

import API

final class WASAPIMock: APIClient {
    var shouldReturnError: Bool = false

    func estimante(_ request: API.EstimateRequest, completion: @escaping API.ResultCallback<API.EstimateResponse>) {
        guard !shouldReturnError else {
            completion(.failure(.invalidParam))
            return
        }

        completion(.success(EstimateResponse.mock))
    }

    func confirm(_ request: API.ConfirmRequest, completion: @escaping API.ResultCallback<API.SuccessResponse>) {
        guard !shouldReturnError else {
            completion(.failure(.invalidParam))
            return
        }

        completion(.success(.init(success: true)))
    }

    func rides(_ request: API.RidesRequest, completion: @escaping API.ResultCallback<API.RidesResponse>) {
        guard !shouldReturnError else {
            completion(.failure(.invalidParam))
            return
        }

        completion(.success(.mock))
    }

    func users(completion: @escaping API.ResultCallback<[API.UsersResponse]>) {
        guard !shouldReturnError else {
            completion(.failure(.invalidParam))
            return
        }
    }
}
