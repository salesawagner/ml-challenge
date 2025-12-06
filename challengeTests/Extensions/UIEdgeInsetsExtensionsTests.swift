//
//  UIEdgeInsetsExtensionsTests.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import XCTest
@testable import challenge

final class UIEdgeInsetsExtensionsTests: XCTestCase {
    // MARK: - All Sides Tests

    func test_all_whenCalledWithValue_shouldSetAllEdgesCorrectly() {
        // Given
        let constant: CGFloat = 16.0

        // When
        let result = UIEdgeInsets.all(constant: constant)

        // Then
        XCTAssertEqual(result.top, constant, "top edge matches input value")
        XCTAssertEqual(result.left, constant, "left edge matches input value")
        XCTAssertEqual(result.bottom, constant, "bottom edge matches input value")
        XCTAssertEqual(result.right, constant, "right edge matches input value")
    }

    func test_all_whenCalledWithZero_shouldReturnZeroInsets() {
        // Given
        let constant: CGFloat = 0

        // When
        let result = UIEdgeInsets.all(constant: constant)

        // Then
        XCTAssertEqual(result, .zero, "returns standard zero insets")
    }

    func test_all_whenCalledWithNegativeValue_shouldAcceptNegativeValues() {
        // Given
        let constant: CGFloat = -10.0

        // When
        let result = UIEdgeInsets.all(constant: constant)

        // Then
        XCTAssertEqual(result.top, constant, "handles negative top value")
        XCTAssertEqual(result.bottom, constant, "handles negative bottom value")
    }

    // MARK: - Horizontal Tests

    func test_horizontal_whenCalledWithValue_shouldSetLeftAndRightOnly() {
        // Given
        let constant: CGFloat = 24.0

        // When
        let result = UIEdgeInsets.horizontal(constant: constant)

        // Then
        XCTAssertEqual(result.left, constant, "left gets correct horizontal padding")
        XCTAssertEqual(result.right, constant, "right gets correct horizontal padding")
        XCTAssertEqual(result.top, 0, "top stays at zero")
        XCTAssertEqual(result.bottom, 0, "bottom stays at zero")
    }

    func test_horizontal_whenCalledWithZero_shouldReturnZeroHorizontalInsets() {
        // Given
        let constant: CGFloat = 0

        // When
        let result = UIEdgeInsets.horizontal(constant: constant)

        // Then
        XCTAssertEqual(result, .zero, "all edges default to zero")
    }
}
