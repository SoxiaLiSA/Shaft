//
//  RecmdIllust.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

import Foundation

struct RecmdIllust: Codable {
    let illusts: [Illust]
    let next_url: String?
}


struct Illust: Codable, Identifiable, Equatable {
    let id: Int
    let caption: String?
    let createDate: String?
    let height: Int
    let imageUrls: ImageUrls?
    let isBookmarked: Bool?
    let illustAIType: Int
    let isMuted: Bool?
    let metaPages: [MetaPage]?
    let metaSinglePage: MetaSinglePage?
    let pageCount: Int
    let restrict: Int?
    let sanityLevel: Int?
    let series: Series?
    let tags: [Tag]?
    let title: String?
    let tools: [String]?
    let totalBookmarks: Int?
    let totalView: Int?
    let type: String?
    let user: User?
    let visible: Bool?
    let width: Int
    let xRestrict: Int?
    
    
    static func == (lhs: Illust, rhs: Illust) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id
        case caption
        case createDate = "create_date"
        case height
        case imageUrls = "image_urls"
        case isBookmarked = "is_bookmarked"
        case illustAIType = "illust_ai_type"
        case isMuted = "is_muted"
        case metaPages = "meta_pages"
        case metaSinglePage = "meta_single_page"
        case pageCount = "page_count"
        case restrict
        case sanityLevel = "sanity_level"
        case series
        case tags
        case title
        case tools
        case totalBookmarks = "total_bookmarks"
        case totalView = "total_view"
        case type
        case user
        case visible
        case width
        case xRestrict = "x_restrict"
    }
}

// MARK: - ImageUrls


// MARK: - MetaPage
struct MetaPage: Codable {
    let imageUrls: ImageUrls?

    enum CodingKeys: String, CodingKey {
        case imageUrls = "image_urls"
    }
}

// MARK: - MetaSinglePage
struct MetaSinglePage: Codable {
    let originalImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case originalImageUrl = "original_image_url"
    }
}

// MARK: - Tag
struct Tag: Codable {
    let name: String?
    let translatedName: String?

    var tagName: String? {
        return name ?? translatedName
    }

    enum CodingKeys: String, CodingKey {
        case name
        case translatedName = "translated_name"
    }
}

// MARK: - User


// MARK: - Series (Placeholder)
struct Series: Codable {
    // 根据实际字段补充
}
