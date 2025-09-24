//
//  ShaftApp.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

import SwiftUI

import Foundation
import Combine

import Foundation
import Combine

class AuthManager: ObservableObject {
    
    static let shared = AuthManager()  // <- 单例
    
    @Published var isLoggedIn: Bool = false
    
    private let tokenKey = "authToken"

    init() {
        if getToken() != nil {
            isLoggedIn = true
        }
    }

    // 登录
    func login(tokenData: TokenData) {
        if let data = try? JSONEncoder().encode(tokenData) {
            UserDefaults.standard.set(data, forKey: tokenKey)
            isLoggedIn = true
        }
    }

    // 登出
    func logout() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        isLoggedIn = false
    }

    // 获取 token
    func getToken() -> String? {
        guard let data = UserDefaults.standard.data(forKey: tokenKey) else { return nil }
        return try? JSONDecoder().decode(TokenData.self, from: data).accessToken
    }
    
    func saveToken(_ newToken: String) { }
}



@main
struct ShaftApp: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                HomeView()
                    .environmentObject(authManager)
            } else {
                LandingView()
                    .environmentObject(authManager)
            }
        }
    }
}
