//
//  DoubleExtensionsTests.swift
//  challenge
//
//  Created by Wagner Sales
//

import XCTest
@testable import challenge

final class DoubleExtensionTests: XCTestCase {
    func testToBRLValidValues() {
        let value: Double = 1234.56
        XCTAssertEqual(value.toBRL, "1.234,56")
    }

    func testToBRLZeroValue() {
        let value: Double = .zero
        let formattedValue = value.toBRL
        XCTAssertEqual(formattedValue, "0,00")
    }

    func testToKMValidValues() {
        let value: Double = 1234.567
        let formattedValue = value.toKM
        XCTAssertEqual(formattedValue, "1.234,57 km")
    }

    func testToKMZeroValue() {
        let value: Double = .zero
        let formattedValue = value.toKM
        XCTAssertEqual(formattedValue, "0 km")
    }
}
