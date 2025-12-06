//
//  MockDecodableRequest 2.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

struct MockDecodableRequest: APIRequest {
    typealias Response = MockProduct
    typealias ErrorResponse = GenericErrorResponse

    var httpMethod: APIHTTPMethod { .get }
    var resourceName: String { "products" }
}
