//
//  HTMLExtensions.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Elementary
import Views

extension HTML {
    func environment(user: App.User?) -> some HTML {
        guard let user else {
            return self.environment(EnvironmentValue.$user, .init(isLoggedIn: false))
        }
        return self.environment(EnvironmentValue.$user, user.toViewUser(isLoggedIn: true))
    }
}
