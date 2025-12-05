//
//  RidesResponse.swift
//  challenge
//
//  Created by Wagner Sales
//

import API

extension RidesResponse {
    static var mock: RidesResponse {
        .init(customerId: "", rides: [.mock])
    }
}
