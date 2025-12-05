//
//  Logger.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import os

protocol LoggerProtocol {
    static func log(title: String, message: String, type: OSLogType)
}

final class Logger: LoggerProtocol {
    static func log(title: String, message: String, type: OSLogType = .info) {
        let logMessage = """
        <<LOGGER>>
        \(title)
        \(message)
        <<LOGGER>>
        """

        os_log("%{public}@", log: .default, type: type, logMessage)
    }
}
