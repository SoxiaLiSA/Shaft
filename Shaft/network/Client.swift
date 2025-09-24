//
//  Client.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

import Foundation
import CryptoKit
import Alamofire



// MARK: - Client
final class Client {
    static let shared = Client()
    private init() {}

    private let tokenRefresher = TokenRefresher()

    enum Base { case app, oauth, web }

    private let appApiHost = "https://app-api.pixiv.net"
    private let oauthHost = "https://oauth.secure.pixiv.net"
    private let webApiHost = "https://www.pixiv.net"

    private func buildUrl(_ base: Base?, path: String) throws -> String {
        switch base {
        case .app: return appApiHost + path
        case .oauth: return oauthHost + path
        case .web: return webApiHost + path
        case .none: throw URLError(.badURL)
        }
    }

    private func isTokenError(_ data: Data?) -> Bool {
        guard let str = data.flatMap({ String(data: $0, encoding: .utf8) }) else { return false }
        return str.contains(TokenError.error1) || str.contains(TokenError.error2)
    }

    // 核心请求方法
    private func performRequest<T: Codable>(
        url: String,
        method: HTTPMethod,
        headers: HTTPHeaders,
        body: Data?
    ) async throws -> T {
        Logger.request(url, method: method, headers: headers, body: body)

        let response: DataResponse<T, AFError> = await AF.request(url, method: method, headers: headers) {
            if let body {
                $0.httpBody = body
                $0.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        .serializingDecodable(T.self)
        .response

        Logger.response(status: response.response?.statusCode, data: response.data)

        if let value = response.value {
            return value
        } else {
            throw URLError(.badServerResponse)
        }
    }

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

            let headers = NetworkHeaders.makeHeaders(needToken: needToken)

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
            if isTokenError(data), let oldToken = AuthManager.shared.getToken() {
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

// MARK: - 示例接口
extension Client {
    func getRecmdIllust() async throws -> RecmdIllust {
        let endpoint = "/v1/illust/recommended?include_privacy_policy=true&filter=for_android&include_ranking_illusts=false"
        return try await requestWithAutoRefresh(url: endpoint, base: .app, method: .get, needToken: true)
    }
}
