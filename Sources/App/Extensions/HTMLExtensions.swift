//
//  HTMLExtensions.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Elementary
import Views

extension HTML where Self: Sendable {
    func environment(user: App.User?) -> some HTML & Sendable {
        guard let user else {
            return self.environment(EnvironmentValue.$user, .init(isLoggedIn: false))
        }
        return self.environment(EnvironmentValue.$user, user.toViewUser(isLoggedIn: true))
    }
}
