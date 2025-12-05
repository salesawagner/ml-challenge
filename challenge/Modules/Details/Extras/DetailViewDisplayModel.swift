//
//  DetailViewDisplayModel.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

struct DetailViewDisplayModel {
    let title: String
    let price: String
    let pictures: [String]

    static func from(_ response: ItemResponse) -> DetailViewDisplayModel {
        .init(
            title: response.title,
            price: response.priceFormatted,
            pictures: response.pictures.map { $0.url }
        )
    }
}
