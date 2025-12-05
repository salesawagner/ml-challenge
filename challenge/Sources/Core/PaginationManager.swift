//
//  ListPaginationManager.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import Foundation

struct PaginationInfo {
    let offset: Int
    let limit: Int
    let total: Int

    var canLoadMore: Bool {
        guard total > 0 else { return true }
        return offset < total
    }

    var hasData: Bool {
        total > .zero
    }
}

protocol PaginationManagerProtocol {
    var offset: Int { get }
    var limit: Int { get }
    var total: Int { get }
    var canLoadMore: Bool { get }
    var info: PaginationInfo { get }
    func updateTotal(_ total: Int)
    func nextPage()
    func reset()
}

final class PaginationManager: PaginationManagerProtocol {
    // MARK: - Properties

    private let initialOffset: Int
    private let initialLimit: Int

    private(set) var offset: Int
    private(set) var limit: Int
    private(set) var total: Int

    // MARK: - Computed Properties

    var canLoadMore: Bool {
        guard total > .zero else {
            return true
        }

        return offset < total
    }

    var info: PaginationInfo {
        PaginationInfo(offset: offset, limit: limit, total: total)
    }

    // MARK: - Initialization

    init(offset: Int = .zero, limit: Int = AppConfiguration.searchLimit) {
        self.initialOffset = offset
        self.initialLimit = limit
        self.offset = offset
        self.limit = limit
        self.total = .zero
    }

    // MARK: - Public Methods

    func updateTotal(_ total: Int) {
        self.total = total
    }

    func nextPage() {
        guard canLoadMore else {
            return
        }

        offset = offset + limit
    }

    func reset() {
        offset = initialOffset
        limit = initialLimit
        total = .zero
    }
}
