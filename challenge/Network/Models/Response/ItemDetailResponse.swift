//
//  ItemResponse.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import Foundation

// MARK: - ItemDescriptionResponse
struct ItemDescriptionResponse: Codable {
    let plainText: String

    enum CodingKeys: String, CodingKey {
        case plainText = "plain_text"
    }
}
