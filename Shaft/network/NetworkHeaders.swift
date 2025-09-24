//
//  NetworkHeaders.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/24.
//

import Foundation
import Alamofire

struct NetworkHeaders {
    
    static func makeHeaders(needToken: Bool) -> HTTPHeaders {
        var headers = HTTPHeaders()
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
}
