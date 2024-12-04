//
//  BlogController.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Foundation
import Vapor
import VaporElementary
import Views
import AsyncAlgorithms
import Afluent

struct BlogController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("blog", use: self.blog)
    }
    
    @Sendable
    func blog(req: Request) async throws -> HTMLResponse {
        HTMLResponse {
            BlogPage(blogs: DeferredTask {
                try await App.BlogPost.query(on: req.db)
                    .with(\.$tags)
                    .with(\.$author)
                    .sort(\.$createdAt, .descending)
                    .all().async
            }
                .toAsyncSequence()
                .flatMap { $0 }
                .map { Views.BlogPost(tags: $0.tags.map(\.canonicalTitle),
                                      title: $0.title,
                                      createdAt: $0.createdAt,
                                      author: $0.author?.toViewUser(isLoggedIn: false), // eventually convert to $0.author
                                      description: $0.description,
                                      content: $0.content) }
                .eraseToAnyAsyncSequence())
        }
    }
}
