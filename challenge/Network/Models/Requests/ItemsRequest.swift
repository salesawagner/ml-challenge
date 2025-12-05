private enum Attributes: String, CaseIterable {
    case id
    case title
    case price
    case thumbnail
    case pictures
}

struct ItemsRequest: APIRequest {
    typealias Response = [ItemResponse]
    typealias ErrorResponse = GenericErrorResponse

    var httpMethod: APIHTTPMethod {
        .get
    }

    var header: [String: String]? {
        getAuthorizationHeader()
    }

    var resourceName: String {
        "items"
    }

    let itemsId: [String]

    var ids: String {
        itemsId.joined(separator: ",")
    }

    var attributes: String {
        // Warning: If you change the attributes, you will need to change the ItemResponse
        Attributes.allCases.map(\.rawValue).joined(separator: ",")
    }

    enum CodingKeys: String, CodingKey {
        case ids
        case attributes
    }

    init(itemsId: [String]) {
        self.itemsId = itemsId
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ids, forKey: .ids)
        try container.encode(attributes, forKey: .attributes)
    }
}
