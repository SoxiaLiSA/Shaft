//
//  IllustDetailView.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/24.
//

import SwiftUI
import Kingfisher


struct IllustDetailView: View {
    let illust: Illust
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("插画 ID: \(illust.id)")
                .font(.title2)
                .bold()
            
            if let title = illust.title {
                Text("标题: \(title)")
                    .font(.body)
            }
            
            if let author = illust.user?.name {
                Text("作者: \(author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("插画详情")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemBackground)) // 适配深浅色模式
    }
}
