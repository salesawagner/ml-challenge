//
//  EstimateResponse.swift
//  challenge
//
//  Created by Wagner Sales
//

import API

extension EstimateResponse {
    static var mock: EstimateResponse {
        .init(origin: .mock, destination: .mock, distance: 0, duration: 0, drivers: [.mock], routeResponse: .mock)
    }
}
