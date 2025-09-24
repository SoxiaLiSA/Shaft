//
//  TokenData.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

import Foundation

struct TokenData: Codable, Sendable {
    let accessToken: String
    let expiresIn: Int
    let refreshToken: String
    let user: User

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case user
    }
}
