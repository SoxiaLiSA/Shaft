//
//  Client.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

import Foundation
import CryptoKit



final class Client {
    static let shared = Client()

    private init() {}

    // MARK: - API 基础 URL
    private let appApiHost = "https://app-api.pixiv.net"
    private let oauthHost = "https://oauth.secure.pixiv.net"
    private let webApiHost = "https://www.pixiv.net"


    // MARK: - 公共 Header
    private func makeHeaders(needToken: Bool) -> [String: String] {
        var headers: [String: String] = [:]
        let nonce = RequestNonce.build()
        
        if needToken {
            if let token = AuthManager.shared.getToken() {
                headers["authorization"] = "Bearer \(token)"
                print("[Header] 使用 Token:", token)
            } else {
                print("[Header] 需要 Token，但 accessToken 为 nil")
            }
        } else {
            print("[Header] 不需要 Token")
        }
        
        
        headers["accept-language"] = "zh_CN"
        headers["app-os"] = "ios"
        headers["app-version"] = "7.13.4"
        headers["x-client-time"] = nonce.xClientTime
        headers["x-client-hash"] = nonce.xClientHash
        headers["user-agent"] = "PixivIOSApp/7.13.4 (iOS 16.0; iPhone)"
        
        print("[Header] 完整 Header:", headers)
        
        return headers
    }


    func request<T: Codable>(
        url: String,
        base: Base? = .app,          // 改为可选
        method: String = "GET",
        body: Data? = nil,
        needToken: Bool = true
    ) async throws -> T {

        let fullUrl: URL
        if url.hasPrefix("http") {
            // 如果传入完整 URL，直接使用
            guard let u = URL(string: url) else {
                throw URLError(.badURL)
            }
            fullUrl = u
        } else {
            // 仍然使用 base 拼接
            switch base {
            case .app:
                fullUrl = URL(string: appApiHost + url)!
            case .oauth:
                fullUrl = URL(string: oauthHost + url)!
            case .web:
                fullUrl = URL(string: webApiHost + url)!
            case .none:
                throw URLError(.badURL) // base 为 nil，但 url 不是完整 URL
            }
        }


        var request = URLRequest(url: fullUrl)
        request.httpMethod = method
        request.httpBody = body
        makeHeaders(needToken: needToken).forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        print("发起请求 URL:", fullUrl)
        print("请求 Header:", request.allHTTPHeaderFields ?? [:])

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP 状态码:", httpResponse.statusCode)
        }

        if let json = String(data: data, encoding: .utf8) {
            print("返回 JSON:", json)
        }

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("JSON 解析失败:", error)
            throw error
        }
    }


    enum Base {
        case app
        case oauth
        case web
    }
}


actor TokenRefresher {
    private var refreshingTask: Task<String, Error>? = nil

    /// 保证同一时间只刷新一次 token
    func refreshIfNeeded(oldToken: String) async throws -> String {
        // 如果已有刷新任务，直接等待结果
        if let task = refreshingTask {
            return try await task.value
        }

        // 没有刷新任务，则创建一个
        let task = Task<String, Error> {
            defer { refreshingTask = nil } // 完成后清理
            print("[Token] 开始刷新 token")
            let newToken = "newly_token"
            AuthManager.shared.saveToken(newToken)
            return newToken
        }

        refreshingTask = task
        return try await task.value
    }
}



let tokenRefresher = TokenRefresher()

extension Client {
    
    /// 获取推荐榜单
        func getRecmdIllust() async throws -> RecmdIllust {
            let endpoint = "/v1/illust/recommended?include_privacy_policy=true&filter=for_android&include_ranking_illusts=false"
            return try await request(url: endpoint, base: .app, method: "GET", needToken: true)
        }
    
    
    
    /// 判断接口返回是否是 token 错误
       func isTokenError(response: HTTPURLResponse, data: Data?) -> Bool {
           // 1️⃣ 先判断状态码
           guard response.statusCode == 400 else { return false }
           
           // 2️⃣ 转成字符串
           guard let jsonString = data.flatMap({ String(data: $0, encoding: .utf8) }) else {
               return false
           }
           
           // 3️⃣ 判断是否包含 token 错误标识
           return jsonString.contains("Error occurred at the OAuth process") ||
                  jsonString.contains("Invalid refresh token")
       }
    
    

    func requestWithAutoRefresh<T: Codable>(
        url: String,
        base: Base? = .app,
        method: String = "GET",
        body: Data? = nil,
        needToken: Bool = true
    ) async throws -> T {
        
        do {
            return try await request(url: url, base: base, method: method, body: body, needToken: needToken)
        } catch {
//            // 捕获请求失败的错误
//            if let responseError = error as? HTTPError,  // 你 request 方法里面可以把响应码封装成 HTTPError
//               let httpResponse = responseError.response,
//               let data = responseError.data,
//               isTokenError(response: httpResponse, data: data),
//               let oldToken = AuthManager.shared.getToken() {
//
//                // 刷新 token（同一时间只刷新一次）
//                let newToken = try await tokenRefresher.refreshIfNeeded(oldToken: oldToken)
//
//                // 使用新 token 重试一次
//                return try await request(url: url, base: base, method: method, body: body, needToken: needToken)
//            } else {
//
//            }
            throw error
        }
    }

}
