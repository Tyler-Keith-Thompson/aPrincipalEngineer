//
//  BlogController.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Foundation
import Vapor
import VaporElementary
import VaporCSRF
import Views
import AsyncAlgorithms
import Afluent
import Fluent
import DependencyInjection

struct BlogController: RouteCollection {
    @Injected(Container.openFGAService) private var openFGAService
    
    func boot(routes: RoutesBuilder) throws {
        let blog = routes.grouped(User.sessionAuthenticator()).grouped("blog")
        blog.get(use: self.blogSearch)
        blog.get(":blogID", use: self.postWithID)
        let console = blog
            .grouped(User.sessionAuthenticator())
            .grouped(UserBearerAuthenticator())
            .grouped(User.guardMiddleware())
        
        console.group("new_post") { newPost in
            newPost.get(use: self.newPost)
            newPost.grouped(CSRFMiddleware())
                .post("web_publish", use: self.webPublish)
        }
    }
    
    struct CreatePostRequest: Content {
        let post_content: String
    }
    @Sendable
    func webPublish(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        guard try await openFGAService.checkAuthorization(
            client: req.client,
            .init(user: user, relation: .can_author, object: BlogPost.new),
            contextualTuples:
                    .init(user: System.global, relation: .system, object: BlogPost.new)
        ) else {
            throw Abort(.unauthorized)
        }
        let request = try req.content.decode(CreatePostRequest.self)
        try await req.db.transaction { database in
            let post = BlogPost(status: .published,
                                title: "TEST",
                                description: "TEST",
                                content: request.post_content,
                                author: user)
            try await post.save(on: database)
            try await openFGAService.createRelation(client: req.client,
                                                    .init(user: .init(type: "user", id: "*"), relation: .viewer, object: post),
                                                    .init(user: .init(type: "guest", id: "*"), relation: .viewer, object: post),
                                                    .init(user: user, relation: .author, object: post)
            )
        }
        return req.redirect(to: "/blog")
    }
    
    @Sendable
    func newPost(req: Request) async throws -> HTMLResponse {
        let user = try req.auth.require(User.self)
        guard try await openFGAService.checkAuthorization(
            client: req.client,
            .init(user: user, relation: .can_author, object: BlogPost.new),
            contextualTuples:
                    .init(user: System.global, relation: .system, object: BlogPost.new)
        ) else {
            throw Abort(.unauthorized)
        }
        return HTMLResponse {
            NewPostPage()
                .environment(user: req.auth.get(User.self))
                .environment(csrfToken: req.csrf.storeToken())
        }
    }
    
    @Sendable
    func postWithID(req: Request) async throws -> HTMLResponse {
        guard let blogIDString = req.parameters.get("blogID"),
              let blogID = UUID(uuidString: blogIDString),
              let post = try await BlogPost.query(on: req.db).filter(\._$id == blogID).with(\.$author).with(\.$tags).first() else {
            throw Abort(.notFound)
        }
        try await req.ensureUser(.can_view, object: post)
        return try HTMLResponse {
            PostDetail(blog: try post.toViewBlogPost()).environment(user: req.auth.get(User.self))
        }
    }
    
    @Sendable
    func blogSearch(req: Request) async throws -> HTMLResponse {
        // really should just check with the system if user can_author_blog_post but I didn't set it up that way
        // will eventually need to refactor, it's just annoying
        let canCreateBlogPost = try await openFGAService.checkAuthorization(
            client: req.client,
            .init(user: req.auth.userTypeTuple, relation: .can_author, object: BlogPost.new),
            contextualTuples:
                    .init(user: System.global, relation: .system, object: BlogPost.new)
        )
        return HTMLResponse {
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
            ).environment(user: req.auth.get(User.self), canCreateBlogPost: canCreateBlogPost)
        }
    }
}

struct NewBlogPost: OpenFGAModel {
    typealias Relation = BlogPost.Relation
    
    var openFGAID: String { "next" }
    
    var openFGATypeName: String { "blog_post" }
}

extension BlogPost {
    static let new = NewBlogPost()
}
