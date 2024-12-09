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
        let posts = try await BlogPost.query(on: req.db)
            .limit(5)
            .with(\.$tags)
            .with(\.$author)
            .sort(\.$createdAt, .descending)
            .all()
        
        return HTMLResponse {
            Index(posts: posts.compactMap { try? $0.toViewBlogPost() }).environment(user: req.auth.get(User.self))
        }
    }
    
    app.grouped(User.sessionAuthenticator()).get("authors") { req in
        HTMLResponse {
            Authors().environment(user: req.auth.get(User.self))
        }
    }
    
    try app.register(collection: WellKnownController())
    try app.register(collection: MetricsController())
    try app.register(collection: UserController())
    try app.register(collection: ViewController())
    try app.register(collection: BlogController())
}
