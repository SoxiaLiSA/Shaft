//
//  KFImageView.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

import SwiftUI
import Combine // <- 必须导入
import Kingfisher

struct KFImageView: View {
    let url: URL
    
    var body: some View {
        KFImage(url)
            .requestModifier { request in
                request.setValue("https://www.pixiv.net/", forHTTPHeaderField: "Referer")
            }
            .placeholder {
                ZStack {
                    Color.black.opacity(0.1)
                    ProgressView()
                }
                .frame(maxWidth: .infinity, minHeight: 150)
            }
            .onSuccess { result in
                print("[KFImage] 加载成功:", url)
            }
            .onFailure { error in
                print("[KFImage] 加载失败:", url, error)
            }
            .resizable()
            .scaledToFill()
    }
}
