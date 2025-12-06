//
//  MockAPIRequestWithJSON.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

struct MockAPIRequestWithJSON: APIRequest, Encodable {
    typealias Response = String
    typealias ErrorResponse = GenericErrorResponse

    var httpMethod: APIHTTPMethod { .post }
    var resourceName: String
    var serialization: APISerialization { .json }

    let  String = "test"
}
