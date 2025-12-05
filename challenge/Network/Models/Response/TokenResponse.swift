import Foundation

struct TokenResponse: Codable {
    let accessToken, tokenType: String
    let expiresIn: Int
    let userId: Int
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case userId = "user_id"
        case refreshToken = "refresh_token"
    }
}
