//
//  ImageUrls.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

struct ImageUrls: Codable {
    let url: String?
    let large: String?
    let medium: String?
    let original: String?
    let small: String?
    let squareMedium: String?
    let px16x16: String?
    let px170x170: String?
    let px50x50: String?

    enum CodingKeys: String, CodingKey {
        case url, large, medium, original, small
        case squareMedium = "square_medium"
        case px16x16 = "px_16x16"
        case px170x170 = "px_170x170"
        case px50x50 = "px_50x50"
    }
}
