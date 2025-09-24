//
//  TokenRefresher.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/24.
//

import Foundation
import CryptoKit
import Alamofire




// MARK: - Token 刷新器
actor TokenRefresher {
    private var refreshingTask: Task<String, Error>?

    func refreshIfNeeded(oldToken: String) async throws -> String {
        if let task = refreshingTask {
            Logger.info("[Token] 已有刷新任务，等待结果")
            return try await task.value
        }

        let task = Task<String, Error> {
            defer { refreshingTask = nil }
            Logger.info("[Token] 开始刷新 token")

            let form: [String: String] = [
                "client_id": "MOBrBDS8blbauoSck0ZfDbtuzpyT",
                "client_secret": "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj",
                "grant_type": "refresh_token",
                "refresh_token": AuthManager.shared.getRefreshToken() ?? "",
                "include_policy": "true"
            ]

            // 替换前的那段使用 serializingDecodable 的代码 -> 用下面替换
            let dataResponse = await AF.request(
                "https://oauth.secure.pixiv.net/auth/token",
                method: .post,
                parameters: form,
                encoder: URLEncodedFormParameterEncoder.default
            )
            .serializingData()
            .response

            // 打印状态 & 响应体（与你现有风格保持一致）
            if let status = dataResponse.response?.statusCode {
                print("[Token] HTTP 状态码: \(status)")
            } else {
                print("[Token] 未收到 HTTP 响应")
            }

            let responseData = dataResponse.data ?? Data()
            if let jsonString = String(data: responseData, encoding: .utf8) {
                print("[Token] 响应内容: \(jsonString)")
            }

            // 检查状态码
            guard let status = dataResponse.response?.statusCode, 200..<300 ~= status else {
                throw URLError(.badServerResponse)
            }

            // 手动解码（不会触发 Sendable 检查）
            do {
                let decoder = JSONDecoder()
                let tokenData = try decoder.decode(TokenData.self, from: responseData)
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
