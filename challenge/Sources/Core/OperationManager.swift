//
//  OperationManager.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

protocol OperationManagerProtocol {
    func performDelay(_ action: @escaping () async -> Void)
    func performImmediate(_ action: @escaping () async -> Void)
    func cancel()
}

final class OperationManager {
    // MARK: - Properties
    
    private var currentTask: Task<Void, Never>?
    private let delay: Duration
    
    // MARK: - Initialization
    
    init(delay: Duration = .milliseconds(300)) {
        self.delay = delay
    }
    
    deinit {
        cancel()
    }
}

// MARK: - OperationManagerProtocol

extension OperationManager: OperationManagerProtocol {
    func performDelay(_ action: @escaping () async -> Void) {
        currentTask?.cancel()

        currentTask = Task { [delay] in
            do {
                try await Task.sleep(for: delay)

                guard !Task.isCancelled else { return }

                await action()
            } catch {
                Logger.log(title: "TASK", message: "Task was canceled - expected behavior", type: .info)
            }
        }
    }

    func performImmediate(_ action: @escaping () async -> Void) {
        currentTask?.cancel()

        currentTask = Task {
            guard !Task.isCancelled else { return }
            await action()
        }
    }

    func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }
}
