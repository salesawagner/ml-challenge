//
//  APIBodyEncoding.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

enum APISerialization {
    case query
    case json
    case formUrlEncoded([String: String])
}
