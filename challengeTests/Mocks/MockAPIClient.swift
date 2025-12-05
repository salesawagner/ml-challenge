//
//  MockAPIClient.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

@testable import challenge

final class MockAPIClient: Spy<MockAPIClient.Message>  {
    enum Message {
        case send
    }

    var sendResult: Result<Any, APIError>?
    var localService = APIClient(environment: EnvironmentFactory.createEnvironment(for: .local))

}
