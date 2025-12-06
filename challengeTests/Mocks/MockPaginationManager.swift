//
//  MockPaginationManager.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import Foundation
@testable import challenge

final class MockPaginationManager: Spy<MockPaginationManager.Message> {
    enum Message {
        case updateTotal
        case nextPage
        case reset
    }
    // MARK: - Properties

    var offsetValue: Int = 0
    var limitValue: Int = 20
    var totalValue: Int = 0
    var canLoadMoreValue: Bool = true

    var updateTotalValue: Int?

    var nextPageCallCount: Int {
        receivedMessages.filter { $0 == .nextPage }.count
    }
}

// MARK: - MockResetable

extension MockPaginationManager: MockResetable {
    func resetMock() {
        removeAllMessages()
        offsetValue = 0
        limitValue = 20
        totalValue = 0
        canLoadMoreValue = true
        updateTotalValue = nil
    }
}

// MARK: - PaginationManagerProtocol

extension MockPaginationManager: PaginationManagerProtocol {
    var offset: Int {
        offsetValue
    }

    var limit: Int {
        limitValue
    }

    var total: Int {
        totalValue
    }

    var canLoadMore: Bool {
        canLoadMoreValue
    }

    var info: PaginationInfo {
        PaginationInfo(offset: offset, limit: limit, total: total)
    }

    func updateTotal(_ total: Int) {
        record(.updateTotal)
        updateTotalValue = total
        totalValue = total
    }

    func nextPage() {
        record(.nextPage)
        offsetValue += limitValue
    }

    func reset() {
        record(.reset)
        offsetValue = 0
        totalValue = 0
    }
}
