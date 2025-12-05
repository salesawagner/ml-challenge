struct RefreshTokenRequest: APIRequest {
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
            CodingKeys.refreshToken.rawValue: refreshToken
        ])
    }

    var resourceName: String {
        "oauth/token"
    }

    let grantType: String = "refresh_token"
    let clientId: String
    let clientSecret: String
    let redirectUri: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case redirectUri = "redirect_uri"
        case refreshToken = "refresh_token"
    }
}
