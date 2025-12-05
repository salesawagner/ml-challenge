//
//  HTTPParameter.swift
//  API
//
//  Created by Wagner Sales
//

import Foundation

enum HTTPParameter: CustomStringConvertible, Decodable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case array([String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let array = try? container.decode([String].self) {
            self = .array(array)
        } else {
            throw APIError.invalidParam
        }
    }

    var description: String {
        switch self {
        case .string(let string): return string
        case .bool(let bool): return String(describing: bool)
        case .int(let int): return String(describing: int)
        case .double(let double): return String(describing: double)
        case .array(let array): return String(describing: array)
        }
    }
}
