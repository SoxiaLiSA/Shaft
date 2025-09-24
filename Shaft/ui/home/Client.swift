//
//  Client.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

import Foundation
import CryptoKit
import Alamofire

struct TokenError {
    static let error1 = "Error occurred at the OAuth process"
    static let error2 = "Invalid refresh token"
}


actor TokenRefresher {
    private var refreshingTask: Task<String, Error>? = nil
    
    func refreshIfNeeded(oldToken: String) async throws -> String {
        if let task = refreshingTask {
            print("[Token] 已有刷新任务，等待结果")
            return try await task.value
        }

        let task = Task<String, Error> {
            defer { refreshingTask = nil }
            print("[Token] 开始刷新 token")

            // 请求参数
            let form: [String: String] = [
                "client_id": "MOBrBDS8blbauoSck0ZfDbtuzpyT",
                "client_secret": "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj",
                "grant_type": "refresh_token",
                "refresh_token": AuthManager.shared.getRefreshToken() ?? "",
                "include_policy": "true"
            ]
            print("[Token] 请求参数: \(form)")

            // 发起请求
            let dataResponse = await AF.request(
                "https://oauth.secure.pixiv.net/auth/token",
                method: .post,
                parameters: form,
                encoder: URLEncodedFormParameterEncoder.default
            )
            .serializingData()
            .response

            // 状态码
            if let status = dataResponse.response?.statusCode {
                print("[Token] HTTP 状态码: \(status)")
            } else {
                print("[Token] 未收到 HTTP 响应")
            }

            // 响应内容
            if let data = dataResponse.data, let jsonString = String(data: data, encoding: .utf8) {
                print("[Token] 响应内容: \(jsonString)")
            } else {
                print("[Token] 响应内容为空")
            }

            // 检查状态码
            guard let status = dataResponse.response?.statusCode, 200..<300 ~= status else {
                throw URLError(.badServerResponse)
            }

            // 解码
            guard let data = dataResponse.data else {
                print("[Token] 无法获取数据解码")
                throw URLError(.cannotDecodeRawData)
            }

            do {
                let decoder = JSONDecoder()
                // 不使用 keyDecodingStrategy，直接用 CodingKeys 映射
                let tokenData = try decoder.decode(TokenData.self, from: data)

                print("[Token] 解码成功: accessToken=\(tokenData.accessToken), refreshToken=\(tokenData.refreshToken)")
                AuthManager.shared.updateTokenData(tokenData: tokenData)
                return tokenData.accessToken
            } catch {
                print("[Token] JSON 解码失败: \(error)")
                throw error
            }

        }

        refreshingTask = task
        return try await task.value
    }



}



let tokenRefresher = TokenRefresher() // <- 这是全局实例


import Alamofire

final class Client {
    static let shared = Client()
    private init() {}

    private let tokenRefresher = TokenRefresher()

    enum Base { case app, oauth, web }

    private let appApiHost = "https://app-api.pixiv.net"
    private let oauthHost = "https://oauth.secure.pixiv.net"
    private let webApiHost = "https://www.pixiv.net"

    private func makeHeaders(needToken: Bool) -> HTTPHeaders {
        var headers = HTTPHeaders() // <-- Alamofire 5+ 正确初始化方式
        let nonce = RequestNonce.build()

        if needToken, let token = AuthManager.shared.getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }

        headers.add(name: "Accept-Language", value: "zh_CN")
        headers.add(name: "App-OS", value: "ios")
        headers.add(name: "App-Version", value: "7.13.4")
        headers.add(name: "X-Client-Time", value: nonce.xClientTime)
        headers.add(name: "X-Client-Hash", value: nonce.xClientHash)
        headers.add(name: "User-Agent", value: "PixivIOSApp/7.13.4 (iOS 16.0; iPhone)")

        return headers
    }


    private func isTokenError(data: Data?) -> Bool {
        guard let jsonString = data.flatMap({ String(data: $0, encoding: .utf8) }) else {
            return false
        }
        return jsonString.contains(TokenError.error1) || jsonString.contains(TokenError.error2)
    }

    
    func request<T: Codable>(
        url: String,
        base: Base? = .app,
        method: HTTPMethod = .get,
        body: Data? = nil,            // JSON body
        encoder: ParameterEncoder = JSONParameterEncoder.default,
        needToken: Bool = true
    ) async throws -> T {
        
        let fullUrl: String
        switch base {
        case .app: fullUrl = appApiHost + url
        case .oauth: fullUrl = oauthHost + url
        case .web: fullUrl = webApiHost + url
        case .none: throw URLError(.badURL)
        }

        let headers = makeHeaders(needToken: needToken)
        
        // 打印请求信息
        print("➡️ Request URL: \(fullUrl)")
        print("➡️ Method: \(method.rawValue)")
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("➡️ Body: \(bodyString)")
        }
        print("➡️ Headers: \(headers)")

        let dataResponse: DataResponse<Data, AFError> = await AF.request(
            fullUrl,
            method: method,
            headers: headers
        ) { request in
            if let body = body {
                request.httpBody = body
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        .validate(statusCode: 200..<300) // <- 关键
        .serializingData()
        .response

        if let status = dataResponse.response?.statusCode {
            print("⬅️ Status code: \(status)")
        } else {
            print("⬅️ No response status code")
        }

        if let data = dataResponse.data,
           let dataString = String(data: data, encoding: .utf8) {
            print("⬅️ Response data: \(dataString)")
        } else {
            print("⬅️ No response data")
        }

        guard let status = dataResponse.response?.statusCode, 200..<300 ~= status else {
            throw URLError(.badServerResponse)
        }

        guard let data = dataResponse.data else {
            throw URLError(.cannotDecodeRawData)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }


}


// MARK: - 自动刷新 Token
extension Client {

    func requestWithAutoRefresh<T: Codable>(
        url: String,
        base: Base? = .app,
        method: HTTPMethod = .get,
        body: Data? = nil,
        encoder: ParameterEncoder = JSONParameterEncoder.default,
        needToken: Bool = true
    ) async throws -> T {

        print("🔹 [AutoRefresh] 开始请求: \(url)")

        // 封装一个内部方法，支持重试
        func performRequest() async throws -> T {
            let fullUrl: String
            switch base {
            case .app: fullUrl = appApiHost + url
            case .oauth: fullUrl = oauthHost + url
            case .web: fullUrl = webApiHost + url
            case .none: throw URLError(.badURL)
            }

            let headers = makeHeaders(needToken: needToken)

            print("➡️ Request URL: \(fullUrl)")
            print("➡️ Method: \(method.rawValue)")
            if let body = body, let bodyString = String(data: body, encoding: .utf8) {
                print("➡️ Body: \(bodyString)")
            }
            print("➡️ Headers: \(headers)")

            let dataResponse: DataResponse<Data, AFError> = await AF.request(
                fullUrl,
                method: method,
                headers: headers
            ) { request in
                if let body = body {
                    request.httpBody = body
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            }
            .serializingData()
            .response

            if let status = dataResponse.response?.statusCode {
                print("⬅️ Status code: \(status)")
            }

            let data = dataResponse.data ?? Data()
            if let dataString = String(data: data, encoding: .utf8) {
                print("⬅️ Response data: \(dataString)")
            }

            // 检查返回 JSON 是否包含 token 错误文案
            if isTokenError(data: data), let oldToken = AuthManager.shared.getToken() {
                print("[Token] 检测到 Token 错误，旧 Token: \(oldToken)")
                let newToken = try await tokenRefresher.refreshIfNeeded(oldToken: oldToken)
                print("[Token] 刷新完成，新 Token: \(newToken)")
                return try await performRequest() // 重试
            }

            // 检查 HTTP 状态码
            if let status = dataResponse.response?.statusCode, !(200..<300).contains(status) {
                throw URLError(.badServerResponse)
            }

            return try JSONDecoder().decode(T.self, from: data)
        }

        return try await performRequest()
    }
}



struct Empty: Encodable {}

// MARK: - 示例接口
extension Client {
    
    
    func getRecmdIllust() async throws -> RecmdIllust {
        let endpoint = "/v1/illust/recommended?include_privacy_policy=true&filter=for_android&include_ranking_illusts=false"
        return try await requestWithAutoRefresh(url: endpoint, base: .app, method: .get, needToken: true)
    }


}
