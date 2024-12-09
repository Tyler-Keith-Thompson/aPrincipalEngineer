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
                     canCreateBlogPost: Bool = false) -> some HTML & Sendable {
        guard let user else {
            return self.environment(EnvironmentValue.$user,
                                    .init(isLoggedIn: isLoggedIn ?? false,
                                          canCreateBlogPost: canCreateBlogPost))
        }
        return self.environment(EnvironmentValue.$user,
                                user.toViewUser(isLoggedIn: isLoggedIn ?? true,
                                                canCreateBlogPost: canCreateBlogPost))
    }
}
