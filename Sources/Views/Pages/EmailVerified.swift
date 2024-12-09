//
//  EmailVerified.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary

public struct EmailVerified: HTML, Sendable {
    let username: String
    
    public init(username: String) {
        self.username = username
    }
    
    public var content: some HTML {
        DefaultContent(title: "User Profile") {
            h3 { "Hello, \(username)" }
            p {
                "You successfully verified your email!"
            }
        }
    }
}
