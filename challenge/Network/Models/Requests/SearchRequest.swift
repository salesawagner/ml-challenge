struct SearchRequest: APIRequest {
    typealias Response = SearchResponse
    typealias ErrorResponse = GenericErrorResponse

    var httpMethod: APIHTTPMethod {
        .get
    }

    var header: [String: String]? {
        getAuthorizationHeader()
    }

    var resourceName: String {
        "users/\(userId)/items/search"
    }

    let userId: Int
    let offset: Int?
    let limit: Int?
    let query: String?
    let sort: String

    enum CodingKeys: String, CodingKey {
        case offset
        case limit
        case query = "q"
        case sort
    }

    init(userId: Int, offset: Int? = .zero, limit: Int? = 20, query: String? = nil, sort: String = "price_asc") {
        self.userId = userId
        self.offset = offset
        self.limit = limit
        self.query = query
        self.sort = sort
    }
}
