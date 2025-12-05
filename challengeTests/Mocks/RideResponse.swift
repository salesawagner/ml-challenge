//
//  RideResponse.swift
//  challenge
//
//  Created by Wagner Sales
//

import API

extension RideResponse {
    static var mock: RideResponse {
        .init(
            id: 0,
            date: "date",
            origin: "origin",
            destination: "destination",
            distance: 0,
            duration: "duration",
            driver: .mock,
            value: 0
        )
    }
}
