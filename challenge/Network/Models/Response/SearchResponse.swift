import Foundation

struct SearchResponse: Decodable {
    let sellerID: String
    let results: [String]
    let paging: Paging

    enum CodingKeys: String, CodingKey {
        case sellerID = "seller_id"
        case results
        case paging
    }
}

struct Paging: Codable {
    let limit: Int
    let offset: Int
    let total: Int
}
