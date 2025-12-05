//
//  GeoLocationResponseTests.swift
//  challenge
//
//  Created by Wagner Sales
//

import XCTest
import CoreLocation
import API
@testable import challenge

final class GeoLocationResponseTests: XCTestCase {
    func testToCoordinate2D_ValidCoordinates() {
        let latitude = -23.55052
        let longitude = -46.633308
        let geoLocation = GeoLocationResponse(latitude: latitude, longitude: longitude)
        let coordinate = geoLocation.toCoordinate2D

        XCTAssertEqual(coordinate.latitude, latitude)
        XCTAssertEqual(coordinate.longitude, longitude)
    }
}
