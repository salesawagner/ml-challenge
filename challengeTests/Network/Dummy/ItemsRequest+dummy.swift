//
//  ItemsRequest+dummy.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

@testable import challenge

extension ItemsRequest {
    static var dummy: ItemsRequest {
        .init(itemsId: [])
    }
}
