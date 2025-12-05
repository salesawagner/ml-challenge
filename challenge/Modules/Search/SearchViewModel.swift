//
//  SearchViewModel.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

protocol SearchViewModelProtocol {
    var userId: Int { get }
    var searchQuery: String? { get set }
    var isSearchValid: Bool { get }
    var didUpdateValidation: ((Bool) -> Void)? { get set }

    func validateSearch()
    func performSearch() -> String?
}

final class SearchViewModel {
    // MARK: - Properties

    let userId: Int

    var searchQuery: String? {
        didSet {
            validateSearch()
        }
    }

    private(set) var isSearchValid: Bool = false {
        didSet {
            didUpdateValidation?(isSearchValid)
        }
    }

    var didUpdateValidation: ((Bool) -> Void)?

    // MARK: - Private Properties

    private let minimumCharacters: Int = 3

    // MARK: - Initialization

    init(userId: Int) {
        self.userId = userId
    }
}

// MARK: - SearchViewModelProtocol

extension SearchViewModel: SearchViewModelProtocol {
    func validateSearch() {
        guard let query = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty else {
            isSearchValid = false
            return
        }

        isSearchValid = query.count >= minimumCharacters
    }

    func performSearch() -> String? {
        guard isSearchValid, let query = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        return query
    }
}
