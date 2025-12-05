//
//  Logger.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

import os

protocol LoggerProtocol {
    static func log(title: String, message: String?, type: OSLogType)
}

final class Logger: LoggerProtocol {
    static func log(title: String, message: String? = nil, type: OSLogType = .debug) {
        var logMessage = "<</LOGGER>> \n"
        logMessage += "\(title)\n"

        if let message = message {
            logMessage += "\(message)\n"
        }

        logMessage += "<</LOGGER>>"

        os_log("%{public}@", log: .default, type: type, logMessage)
    }
}
