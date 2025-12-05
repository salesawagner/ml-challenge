struct ItemDescriptionRequest: APIRequest {
    typealias Response = ItemDescriptionResponse
    typealias ErrorResponse = GenericErrorResponse

    var httpMethod: APIHTTPMethod {
        .get
    }

    var header: [String: String]? {
        getAuthorizationHeader()
    }

    var resourceName: String {
        "/items/\(itemId)/description"
    }

    let itemId: String

    init(itemId: String) {
        self.itemId = itemId
    }
}
