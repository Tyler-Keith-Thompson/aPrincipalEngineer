//
//  HTMLExtensions.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Elementary
import Views

extension HTML where Self: Sendable {
    func environment(user: App.User?,
                     isLoggedIn: Bool? = nil,
                     canCreateBlogPost: Bool = false,
                     canEditBlogPost: Bool = false) -> some HTML & Sendable {
        guard let user else {
            return self.environment(EnvironmentValue.$user,
                                    .init(isLoggedIn: isLoggedIn ?? false,
                                          canCreateBlogPost: canCreateBlogPost,
                                          canEditBlogPost: canEditBlogPost))
        }
        return self.environment(EnvironmentValue.$user,
                                user.toViewUser(isLoggedIn: isLoggedIn ?? true,
                                                canCreateBlogPost: canCreateBlogPost,
                                                canEditBlogPost: canEditBlogPost))
    }
    
    func environment(csrfToken token: String) -> some HTML & Sendable {
        self.environment(EnvironmentValue.$csrfToken, token)
    }
}
