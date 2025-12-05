//
//  JSONDecoderExtensions.swift
//  API
//
//  Created by Wagner Sales
//

import Foundation

extension JSONDecoder {
    func decodeResponse<R: APIRequest>(request: R, data: Data) throws -> R.Response {
        try self.decode(R.Response.self, from: data)
    }

    func decodeErrorResponse<R: APIRequest>(request: R, data: Data) throws -> R.ErrorResponse {
        try self.decode(R.ErrorResponse.self, from: data)
    }
}
