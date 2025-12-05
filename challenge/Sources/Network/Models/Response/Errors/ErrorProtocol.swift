//
//  ErrorProtocol.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

typealias ErrorResponseProtocol = ErrorProtocol & Decodable

protocol ErrorProtocol {
    var message: String { get }
    var errorCode: ErrorCode { get }
}
