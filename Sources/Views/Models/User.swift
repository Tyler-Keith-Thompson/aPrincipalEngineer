//
//  User.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

public struct User: Sendable {
    let isLoggedIn: Bool
    let email: String
    let canCreateBlogPost: Bool
    let canEditBlogPost: Bool
    
    public init(isLoggedIn: Bool,
                email: String = "",
                canCreateBlogPost: Bool = false,
                canEditBlogPost: Bool = false) {
        self.isLoggedIn = isLoggedIn
        self.email = email
        self.canCreateBlogPost = canCreateBlogPost
        self.canEditBlogPost = canEditBlogPost
    }
}
