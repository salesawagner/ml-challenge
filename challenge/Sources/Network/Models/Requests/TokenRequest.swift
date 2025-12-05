struct TokenRequest: APIRequest {
    typealias Response = TokenResponse
    typealias ErrorResponse = TokenErrorResponse

    var httpMethod: APIHTTPMethod {
        .post
    }

    var serialization: APISerialization {
        .formUrlEncoded([
            CodingKeys.grantType.rawValue: grantType,
            CodingKeys.clientId.rawValue: clientId,
            CodingKeys.clientSecret.rawValue: clientSecret,
            CodingKeys.redirectUri.rawValue: redirectUri,
            CodingKeys.code.rawValue: code
        ])
    }

    var resourceName: String {
        "oauth/token"
    }

    let grantType: String = "authorization_code"
    let clientId: String
    let clientSecret: String
    let code: String
    let redirectUri: String

    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case code
        case redirectUri = "redirect_uri"
    }
}
