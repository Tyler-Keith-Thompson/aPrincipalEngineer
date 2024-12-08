//
//  routes.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Fluent
import Vapor
import VaporElementary
import Views

func routes(_ app: Application) throws {
    app.grouped(User.sessionAuthenticator()).get { req in
        let user = try? req.auth.require(User.self)
        if user != nil {
            return req.redirect(to: "users/profile")
        }
        return try await HTMLResponse {
            Index()
                .environment(user: req.auth.get(User.self))
        }.encodeResponse(for: req)
    }
    
    try app.register(collection: WellKnownController())
    try app.register(collection: MetricsController())
    try app.register(collection: UserController())
    try app.register(collection: ViewController())
    try app.register(collection: BlogController())
}
