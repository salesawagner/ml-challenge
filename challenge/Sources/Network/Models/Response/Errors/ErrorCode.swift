//
//  ErrorCode.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

enum ErrorCode: String, Codable {
    case unauthorized
    case forbidden
    case invalidGrant = "invalid_grant"
    case notFound = "resource not found"
}
