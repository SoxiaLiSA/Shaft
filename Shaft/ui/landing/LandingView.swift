//
//  Untitled.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

import SwiftUI

import SwiftUI

struct LandingView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var tokenJSON: String = "" // 假设输入完整 JSON 字符串

    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $tokenJSON)
                .frame(minHeight: 200)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                .padding()

            Button("Login") {
                guard let data = tokenJSON.data(using: .utf8),
                      let tokenData = try? JSONDecoder().decode(TokenData.self, from: data) else {
                    print("JSON 解析失败")
                    return
                }
                authManager.login(tokenData: tokenData)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}


#Preview {
    LandingView()
        .environmentObject(AuthManager()) // 预览也要注入
}
