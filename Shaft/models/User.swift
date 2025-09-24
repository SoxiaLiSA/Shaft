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
        case gender
        case requirePolicyAgreement = "require_policy_agreement"
        case xRestrict = "x_restrict"
        case comment
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.account = try container.decodeIfPresent(String.self, forKey: .account)
        
        // 尝试先解码 Int，如果失败就解码 String 再转 Int
        if let intId = try? container.decode(Int.self, forKey: .id) {
            self.id = intId
        } else if let stringId = try? container.decode(String.self, forKey: .id),
                  let intFromString = Int(stringId) {
            self.id = intFromString
        } else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "id 既不是 Int 也不是可转换的 String")
        }

        self.isFollowed = try container.decodeIfPresent(Bool.self, forKey: .isFollowed)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.pixivId = try container.decodeIfPresent(String.self, forKey: .pixivId)
        self.profileImageUrls = try container.decodeIfPresent(ImageUrls.self, forKey: .profileImageUrls)
        self.isMailAuthorized = try container.decodeIfPresent(Bool.self, forKey: .isMailAuthorized)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.mailAddress = try container.decodeIfPresent(String.self, forKey: .mailAddress)
        self.gender = try container.decodeIfPresent(Int.self, forKey: .gender)
        self.requirePolicyAgreement = try container.decodeIfPresent(Bool.self, forKey: .requirePolicyAgreement)
        self.xRestrict = try container.decodeIfPresent(Int.self, forKey: .xRestrict)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
    }
}
