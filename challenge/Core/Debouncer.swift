//
//  Debouncer.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

protocol DebouncerProtocol {
    func debounce(_ action: @escaping () async -> Void)
    func cancel()
}

final class Debouncer {
    // MARK: - Properties

    private var task: Task<Void, Never>?
    private let delay: Duration

    // MARK: - Initialization

    init(delay: Duration = .zero) {
        self.delay = delay
    }

    deinit {
        task?.cancel()
    }
}

// MARK: - DebouncerProtocol

extension Debouncer: DebouncerProtocol {
    func debounce(_ action: @escaping () async -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: delay)

            guard !Task.isCancelled else {
                return
            }

            await action()
        }
    }

    func cancel() {
        task?.cancel()
    }
}
