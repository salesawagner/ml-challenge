//
//  ListItemDisplayModel.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

struct ListItemDisplayModel {
    let title: String
    let price: String
    let imageURL: String?

    static func from(_ response: ItemResponse) -> ListItemDisplayModel {
        .init(
            title: response.title,
            price: response.priceFormatted,
            imageURL: response.thumbnail
        )
    }
}
