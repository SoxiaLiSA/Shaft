//
//  User.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

struct User: Codable {
    let account: String?
    let id: Int
    let isFollowed: Bool?
    let name: String?
    let pixivId: String?
    let profileImageUrls: ImageUrls?
    let isMailAuthorized: Bool?
    let isPremium: Bool?
    let mailAddress: String?
    let gender: Int?
    let requirePolicyAgreement: Bool?
    let xRestrict: Int?
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case account, id
        case isFollowed = "is_followed"
        case name
        case pixivId = "pixiv_id"
        case profileImageUrls = "profile_image_urls"
        case isMailAuthorized = "is_mail_authorized"
        case isPremium = "is_premium"
        case mailAddress = "mail_address"
        case gender = "gender"
        case requirePolicyAgreement = "require_policy_agreement"
        case xRestrict = "x_restrict"
        case comment = "comment"
    }
}
