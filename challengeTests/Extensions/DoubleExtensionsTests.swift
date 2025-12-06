//
//  DoubleExtensionsTests.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class DoubleExtensionsTests: XCTestCase {
    // MARK: - toCurrency Tests

    func test_toCurrency_whenZero_shouldReturnFormattedZero() {
        // Given
        let value: Double = 0.0

        // When
        let result = value.toCurrency

        // Then
        XCTAssertEqual(result, "R$ 0,00", "verifies format zero correctly")
    }

    func test_toCurrency_whenPositiveInteger_shouldReturnFormattedValue() {
        // Given
        let value: Double = 100.0

        // When
        let result = value.toCurrency

        // Then
        XCTAssertEqual(result, "R$ 100,00", "verifies format positive integer")
    }

    func test_toCurrency_whenPositiveDecimal_shouldReturnFormattedValue() {
        // Given
        let value: Double = 99.99

        // When
        let result = value.toCurrency

        // Then
        XCTAssertEqual(result, "R$ 99,99", "verifies format positive decimal")
    }

    func test_toCurrency_whenLargeNumber_shouldReturnFormattedValue() {
        // Given
        let value: Double = 1234567.89

        // When
        let result = value.toCurrency

        // Then
        XCTAssertTrue(result.contains("R$"), "verifies contain R$ symbol")
        XCTAssertTrue(result.contains("1.234.567,89") || result.contains("1234567,89"), "verifies format large number")
    }

    func test_toCurrency_whenOneDecimalPlace_shouldRoundToTwoDecimals() {
        // Given
        let value: Double = 10.5

        // When
        let result = value.toCurrency

        // Then
        XCTAssertEqual(result, "R$ 10,50", "verifies pad with trailing zeros")
    }

    func test_toCurrency_whenThreeDecimalPlaces_shouldRoundToTwoDecimals() {
        // Given
        let value: Double = 10.555

        // When
        let result = value.toCurrency

        // Then
        XCTAssertTrue(result == "R$ 10,55" || result == "R$ 10,56", "verifies round to 2 decimal places")
    }

    func test_toCurrency_whenNegativeValue_shouldReturnFormattedNegative() {
        // Given
        let value: Double = -50.0

        // When
        let result = value.toCurrency

        // Then
        XCTAssertTrue(result.contains("R$"), "should contain R$ symbol")
        XCTAssertTrue(result.contains("-") || result.contains("("), "should indicate negative value")
    }

    func test_toCurrency_whenVerySmallValue_shouldReturnFormattedValue() {
        // Given
        let value: Double = 0.01

        // When
        let result = value.toCurrency

        // Then
        XCTAssertEqual(result, "R$ 0,01", "should format very small values")
    }

    func test_toCurrency_whenMaximumDecimalValue_shouldReturnFormattedValue() {
        // Given
        let value: Double = 0.99

        // When
        let result = value.toCurrency

        // Then
        XCTAssertEqual(result, "R$ 0,99", "should format maximum cents value")
    }

    // MARK: - Real World Cases

    func test_toCurrency_whenProductPrice_shouldFormatCorrectly() {
        // Given
        let prices: [Double] = [299.90, 1500.00, 49.99, 10000.00]

        // When / Then
        for price in prices {
            let result = price.toCurrency
            XCTAssertTrue(result.hasPrefix("R$"), "should start with R$ for price \(price)")
            XCTAssertTrue(result.contains(","), "should contain comma for decimals in price \(price)")
        }
    }

    func test_toCurrency_whenRoundingNeeded_shouldRoundCorrectly() {
        // Given
        let value: Double = 10.996

        // When
        let result = value.toCurrency

        // Then
        XCTAssertTrue(result == "R$ 10,99" || result == "R$ 11,00", "ensures round correctly")
    }

    func test_toCurrency_whenMultipleConversions_shouldBeConsistent() {
        // Given
        let value: Double = 100.50

        // When
        let result1 = value.toCurrency
        let result2 = value.toCurrency
        let result3 = value.toCurrency

        // Then
        XCTAssertEqual(result1, result2)
        XCTAssertEqual(result2, result3)
    }
}
