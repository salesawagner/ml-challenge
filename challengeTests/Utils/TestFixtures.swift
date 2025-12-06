//
//  TestFixtures.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

import Foundation
@testable import challenge

enum TestFixtures {
    static let mockItemResponse = ItemResponse(
        title: "iPhone 15 Pro",
        id: "MLB123456",
        thumbnail: "https://example.com/image.jpg",
        price: 7999.90,
        pictures: [
            ItemPicture(
                quality: "high",
                id: "pic1",
                url: "https://example.com/pic1.jpg",
                secureURL: "https://example.com/pic1.jpg",
                size: "800x600",
                maxSize: "1200x900"
            )
        ]
    )

    static func mockItemResponses(count: Int) -> [ItemResponse] {
        (0..<count).map { index in
            ItemResponse(
                title: "Produto \(index + 1)",
                id: "MLB\(index)",
                thumbnail: "https://example.com/image\(index).jpg",
                price: Double((index + 1) * 100),
                pictures: [
                    ItemPicture(
                        quality: "high",
                        id: "pic\(index)",
                        url: "https://example.com/pic\(index).jpg",
                        secureURL: "https://example.com/pic\(index).jpg",
                        size: "800x600",
                        maxSize: "1200x900"
                    )
                ]
            )
        }
    }

    static let mockTokenResponse = TokenResponse(
        accessToken: "mock_access_token_12345",
        tokenType: "Bearer",
        expiresIn: 21600,
        userId: 123456789,
        refreshToken: "mock_refresh_token_67890"
    )

    static let mockItemDescriptionResponse = ItemDescriptionResponse(
        plainText: "Esta é uma descrição de teste do produto."
    )

    static let mockSearchResponse = SearchResponse(
        sellerID: "123456",
        results: ["MLB1", "MLB2", "MLB3"],
        paging: Paging(limit: 20, offset: 0, total: 100)
    )
}
