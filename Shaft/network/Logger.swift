//
//  Logger.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/24.
//

import Foundation
import CryptoKit
import Alamofire

// MARK: - 彩色日志工具
struct Logger {
    static func info(_ message: String) { print("ℹ️ [INFO] \(message)") }
    static func warning(_ message: String) { print("⚠️ [WARN] \(message)") }
    static func error(_ message: String) { print("❌ [ERROR] \(message)") }
    static func event(_ message: String) { print("🔹 [EVENT] \(message)") }
    static func response(_ message: String) { print("🔸 [RESPONSE] \(message)") }
    static func request(_ url: String, method: HTTPMethod, headers: HTTPHeaders, body: Data?) {
        print("➡️ [REQUEST] URL: \(url)")
        print("➡️ Method: \(method.rawValue)")
        if let body, let bodyStr = String(data: body, encoding: .utf8) {
            print("➡️ Body: \(bodyStr)")
        }
        print("➡️ Headers: \(headers)")
    }
    static func response(status: Int?, data: Data?) {
        if let status { print("⬅️ Status code: \(status)") }
        if let data, let str = String(data: data, encoding: .utf8) {
            print("⬅️ Response data: \(str)")
        }
    }
}
