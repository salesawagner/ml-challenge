//
//  RequestFactoryError.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

import Foundation

enum RequestFactoryError: LocalizedError {
    case encodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Falha ao codificar request: \(error.localizedDescription)"
        }
    }
}
