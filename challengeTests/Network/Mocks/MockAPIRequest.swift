//
//  MockAPIRequest.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

struct MockAPIRequest: APIRequest {
    typealias Response = String
    typealias ErrorResponse = GenericErrorResponse

    var httpMethod: APIHTTPMethod { .get }
    var resourceName: String
    var serialization: APISerialization { .query }
}
