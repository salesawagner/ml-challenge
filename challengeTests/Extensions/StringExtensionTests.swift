//
//  StringExtensionTests.swift
//  challenge
//
//  Created by Wagner Sales
//

@testable import challenge
import XCTest

final class StringExtensionTests: XCTestCase {
    func testToDateValidFormat() {
        let dateString = "2024-12-09T15:30:00"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.timeZone = TimeZone.current

        let expectedDate = formatter.date(from: dateString)
        XCTAssertEqual(dateString.toDate, expectedDate)
    }

    func testToDateInvalidFormat() {
        let dateString = "09/12/2024 15:30"
        XCTAssertNil(dateString.toDate)
    }

    func testToDateFormattedValidFormat() {
        let dateString = "2024-12-09T15:30:00"
        let formattedDate = dateString.toDateFormatted
        XCTAssertEqual(formattedDate, "09/12/2024 às 15:30")
    }

    func testToDateFormattedInvalidFormat() {
        let dateString = "invalid-date"
        XCTAssertNil(dateString.toDateFormatted)
    }
}
