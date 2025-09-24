//
//  IllustCell.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//


import SwiftUI
import Kingfisher

struct IllustCell: View {
    let illust: Illust
    
    var body: some View {
        let columnWidth = (UIScreen.main.bounds.width - 8 * 3) / 2 // 左 8 + 中间 8 + 右 8
        VStack(alignment: .leading, spacing: 4) {
            let imageUrlString = illust.imageUrls?.medium ?? illust.imageUrls?.large
            if let urlString = imageUrlString, let url = URL(string: urlString) {
                KFImageView(url: url)
                    .frame(
                        width: columnWidth,
                        height: CGFloat(illust.height) / CGFloat(max(illust.width, 1)) * columnWidth
                    )
                    .clipped()
                    .cornerRadius(8)
            } else {
                Color.gray
                    .frame(width: columnWidth, height: 150)
                    .cornerRadius(8)
            }
        }
    }
}



