//
//  RefreshToken.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Vapor

struct RefreshToken: Content, ExpressibleByStringLiteral, Equatable {
    static var defaultContentType: HTTPMediaType {
        return .plainText
    }
    
    let content: String
    init() {
        content = [UInt8].random(count: 32).base64
    }
    
    init(stringLiteral value: String) {
        content = value
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        content = try container.decode(String.self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(content)
    }
}
