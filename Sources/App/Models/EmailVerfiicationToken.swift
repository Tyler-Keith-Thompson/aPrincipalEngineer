//
//  EmailVerfiicationToken.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Vapor
import Crypto

struct EmailVerificationToken: Content, Equatable {
    static var defaultContentType: HTTPMediaType {
        return .plainText
    }
    
    let content: String
    
    init() {
        content = Data(SHA256.hash(data: [UInt8].random(count: 32)))
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
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
