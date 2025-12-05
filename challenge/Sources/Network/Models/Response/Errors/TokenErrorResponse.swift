struct TokenErrorResponse: ErrorProtocol, Codable {
    let message: String
    let errorCode: ErrorCode

    enum CodingKeys: String, CodingKey {
        case message
        case errorCode = "error"
    }
}
