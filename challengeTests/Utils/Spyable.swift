//
//  Spyable.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

protocol Spyable {
    associatedtype Message: Equatable
    var receivedMessages: [Message] { get }

    func record(_ message: Message)
    func contains(_ message: Message) -> Bool
}

open class Spy<Message: Equatable>: Spyable {
    private(set) var receivedMessages: [Message] = []

    func record(_ message: Message) {
        receivedMessages.append(message)
    }

    func contains(_ message: Message) -> Bool {
        return receivedMessages.contains(message)
    }

    func removeAllMessages() {
        receivedMessages.removeAll()
    }
}
