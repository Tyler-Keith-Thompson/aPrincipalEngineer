//
//  Profile.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary

public struct Profile: HTML, Sendable {
    @Environment(EnvironmentValue.$user) private var user
    
    public init() { }
    
    public var content: some HTML {
        DefaultContent(title: "User Profile") {
            h2 { "Private Area" }
            h3 { "Hello, \(user.email)" }
            p {
                "You successfully entered the private area with a passkey. Try logging out and logging in again with the same passkey."
            }
        }
    }
}
