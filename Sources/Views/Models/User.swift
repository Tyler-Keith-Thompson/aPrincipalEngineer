//
//  User.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

public struct User: Sendable {
    let isLoggedIn: Bool
    let email: String
    
    public init(isLoggedIn: Bool, email: String = "") {
        self.isLoggedIn = isLoggedIn
        self.email = email
    }
}
