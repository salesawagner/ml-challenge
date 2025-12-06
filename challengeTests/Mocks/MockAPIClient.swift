//
//  MockAPIClient.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import Foundation
@testable import challenge

final class MockAPIClient: Spy<MockAPIClient.Message> {
    enum Message {
        case send
    }

    // MARK: - Properties

    var sendCallCount: Int {
        receivedMessages.filter { $0 == .send }.count
    }

    var sendResult: Result<Any, APIError>?
    var sendDelay: Duration = .zero
    var lastRequest: (any APIRequest)?
}

// MARK: - MockResetable

extension MockAPIClient: MockResetable {
    func resetMock() {
        removeAllMessages()
        sendResult = nil
        sendDelay = .zero
        lastRequest = nil
    }
}

// MARK: - APIClientProtocol

extension MockAPIClient: APIClientProtocol {
    func send<R: APIRequest>(_ request: R) async throws -> R.Response {
        record(.send)
        lastRequest = request

        // delay simulation
        if sendDelay > .zero {
            try await Task.sleep(for: sendDelay)
        }

        guard let result = sendResult else {
            do {
                return try getJSONMock(request)
            } catch {
                throw APIError.unknown(error: NSError(domain: "Mock", code: -1), statusCode: nil)
            }
        }

        switch result {
        case .success(let response):
            guard let typedResponse = response as? R.Response else {
                throw APIError.decodingFailed(
                    NSError(domain: "Mock", code: -1),
                    statusCode: nil
                )
            }
            return typedResponse

        case .failure(let error):
            throw error
        }
    }

    private func getJSONMock<R: APIRequest>(_ request: R) throws -> R.Response {
        guard let url = request.localURL else {
            throw APIError.unknown(error: NSError(domain: "Mock", code: -1), statusCode: nil)
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(R.Response.self, from: data)
        } catch {
            throw APIError.unknown(error: NSError(domain: "Mock", code: -1), statusCode: nil)
        }
    }
}
