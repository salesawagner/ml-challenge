//
//  SearchRequest+dummy.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

@testable import challenge

extension SearchRequest {
    static var dummy: SearchRequest {
        .init(userId: 123)
    }
}

extension SearchResponse {
    static var expected: String {
        "3025335088"
    }
}
