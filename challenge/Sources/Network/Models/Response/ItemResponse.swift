//
//  ItemResponse.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

import Foundation

struct ItemResponse: Decodable {
    let title: String
    let id: String
    let thumbnail: String
    let price: Double
    let pictures: [ItemPicture]

    enum CodingKeys: String, CodingKey {
        case body
    }

    enum BodyKeys: String, CodingKey {
        case title, id, thumbnail, price, pictures
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let bodyContainer = try container.nestedContainer(keyedBy: BodyKeys.self, forKey: .body)
        title = try bodyContainer.decode(String.self, forKey: .title)
        id = try bodyContainer.decode(String.self, forKey: .id)
        thumbnail = try bodyContainer.decode(String.self, forKey: .thumbnail)
        price = try bodyContainer.decode(Double.self, forKey: .price)
        pictures = try bodyContainer.decode([ItemPicture].self, forKey: .pictures)
    }

    init(title: String, id: String, thumbnail: String, price: Double, pictures: [ItemPicture]) {
        self.title = title
        self.id = id
        self.thumbnail = thumbnail
        self.price = price
        self.pictures = pictures
    }
}

extension ItemResponse {
    var priceFormatted: String {
        price.toCurrency
    }
}

struct ItemPicture: Codable {
    let quality, id: String
    let url: String
    let secureURL: String
    let size: String
    let maxSize: String

    enum CodingKeys: String, CodingKey {
        case quality
        case id
        case url
        case secureURL = "secure_url"
        case size
        case maxSize = "max_size"
    }
}
