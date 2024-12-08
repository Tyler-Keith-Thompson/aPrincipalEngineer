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
import Fluent
import DependencyInjection

struct BlogController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let blog = routes.grouped("blog")
        blog.get(use: self.blogSearch)
        blog.get(":blogID", use: self.postWithID)
    }
    
    @Sendable
    func postWithID(req: Request) async throws -> HTMLResponse {
        guard let blogIDString = req.parameters.get("blogID"),
              let blogID = UUID(uuidString: blogIDString),
              let post = try await BlogPost.query(on: req.db).filter(\._$id == blogID).with(\.$author).with(\.$tags).first() else {
            throw Abort(.notFound)
        }
        return try HTMLResponse {
            PostDetail(blog: try post.toViewBlogPost())
        }
    }
    
    @Sendable
    func blogSearch(req: Request) async throws -> HTMLResponse {
        HTMLResponse {
            BlogSearchPage(
                blogs: DeferredTask {
                    try await App.BlogPost.query(on: req.db)
                        .with(\.$tags)
                        .with(\.$author)
                        .sort(\.$createdAt, .descending)
                        .all().async
                }
                    .toAsyncSequence()
                    .flatMap { $0 }
                    .map { try $0.toViewBlogPost() }
                    .eraseToAnyAsyncSequence()
            ).environment(user: req.auth.get(User.self))
        }
    }
}
