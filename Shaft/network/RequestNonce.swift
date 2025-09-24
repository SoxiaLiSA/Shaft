//
//  RequestNonce.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

import Foundation
import CryptoKit

struct RequestNonce {
    let xClientTime: String
    let xClientHash: String

    static func build() -> RequestNonce {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let time = formatter.string(from: Date())
        let hash = md5("\(time)28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c")
        return RequestNonce(xClientTime: time, xClientHash: hash)
    }

    static func md5(_ string: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

func md5(_ string: String) -> String {
    let digest = Insecure.MD5.hash(data: Data(string.utf8))
    return digest.map { String(format: "%02x", $0) }.joined()
}
