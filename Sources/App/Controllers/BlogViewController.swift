//
//  BlogViewController.swift
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

struct BlogViewController: RouteCollection {
    @Injected(Container.openFGAService) private var openFGAService
    let container = Container.current
    
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
            newPost.post("web_publish", body: .collect(maxSize: "100kb"), use: self.webPublish)
        }
        
        console.group("edit_post") { editPost in
            editPost.get(":blogID", use: self.editPost)
            editPost.post("web_update", body: .collect(maxSize: "100kb"), use: self.webUpdate)
        }
    }
    
    struct CreatePostRequest: Content {
        let post_title: String
        let post_tags: String
        let post_description: String
        let post_content: String
    }
    @Sendable
    func webPublish(req: Request) async throws -> Response {
        try req.csrf.verifyToken()
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
            let requestTags = Set<String>(request.post_tags.components(separatedBy: " ").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.map { $0.lowercased() })
            let databaseTags = try await Tag.query(on: database).filter(\.$canonicalTitle ~~ requestTags).all()
            let databaseTagNames = Set<String>(databaseTags.map(\.canonicalTitle))
            let newTags = requestTags.subtracting(databaseTagNames).map { Tag(canonicalTitle: $0) }
            var savedTags = [Tag]()
            for tag in newTags {
                try await tag.save(on: database)
                savedTags.append(tag)
            }
            
            let post = BlogPost(status: .published,
                                title: request.post_title,
                                description: request.post_description.replacingOccurrences(of: "\r\n", with: "\n"),
                                content: request.post_content.replacingOccurrences(of: "\r\n", with: "\n"),
                                author: user)
            try await post.save(on: database)
            try await post.$tags.attach(savedTags + databaseTags, on: database)
            
            try await openFGAService.createRelation(client: req.client,
                                                    .init(user: System.global, relation: .system, object: post),
                                                    .init(user: .init(type: "user", id: "*"), relation: .viewer, object: post),
                                                    .init(user: .init(type: "guest", id: "*"), relation: .viewer, object: post),
                                                    .init(user: user, relation: .author, object: post)
            )
        }
        
        return req.redirect(to: "/blog")
    }
    
    struct UpdatePostRequest: Content {
        let post_id: UUID
        let post_title: String
        let post_tags: String
        let post_description: String
        let post_content: String
    }
    @Sendable
    func webUpdate(req: Request) async throws -> Response {
        try req.csrf.verifyToken()
        let user = try req.auth.require(User.self)
        let request = try req.content.decode(UpdatePostRequest.self)
        guard let post = try await BlogPost.query(on: req.db).filter(\._$id == request.post_id).with(\.$author).with(\.$tags).first() else {
            throw Abort(.notFound)
        }
        guard try await openFGAService.checkAuthorization(
            client: req.client,
            .init(user: user, relation: .can_edit, object: post)
        ) else {
            throw Abort(.unauthorized)
        }
        
        try await req.db.transaction { database in
            let requestTags = Set<String>(request.post_tags.components(separatedBy: " ").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.map { $0.lowercased() })
            let databaseTags = try await Tag.query(on: database).filter(\.$canonicalTitle ~~ requestTags).all()
            let databaseTagsNames = Set<String>(databaseTags.map(\.canonicalTitle))
            let databaseTagIDs = databaseTags.compactMap { try? $0.requireID() }
            let usedBlogPostTags = try await BlogPostTag.query(on: database)
                .with(\.$tag)
                .with(\.$blogPost)
                .filter(\.$tag.$id ~~ databaseTagIDs)
                .filter(\.$blogPost.$id != request.post_id)
                .all()
            
            let orphanedTagIDs = Set<UUID>(databaseTags.compactMap(\.id)).subtracting(Set(usedBlogPostTags.map(\.tag).compactMap(\.id)))
            let orphanedTags = databaseTags.filter {
                guard let id = $0.id else { return false }
                return orphanedTagIDs.contains(id)
            }
            
            let newTags = requestTags.subtracting(databaseTagsNames)
            var savedTags = [Tag]()
            for tagName in newTags {
                let tag = Tag(canonicalTitle: tagName)
                try await tag.save(on: database)
                savedTags.append(tag)
            }
            
            post.title = request.post_title
            post.description = request.post_description.replacingOccurrences(of: "\r\n", with: "\n")
            post.content = request.post_content.replacingOccurrences(of: "\r\n", with: "\n")
            try await post.update(on: database)
            try await post.$tags.attach((savedTags + databaseTags).filter { tag in !post.tags.map(\.id).contains(tag.id) }, on: database)

            for tag in orphanedTags {
                try await tag.delete(on: database)
            }
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
    func editPost(req: Request) async throws -> HTMLResponse {
        guard let blogIDString = req.parameters.get("blogID"),
              let blogID = UUID(uuidString: blogIDString),
              let post = try await BlogPost.query(on: req.db).filter(\._$id == blogID).with(\.$author).with(\.$tags).first() else {
            throw Abort(.notFound)
        }
        try await req.ensureUser(.can_edit, object: post)
        return try HTMLResponse {
            try EditPostPage(post: post.toViewBlogPost())
                .environment(user: req.auth.get(User.self), canEditBlogPost: true)
                .environment(csrfToken: req.csrf.storeToken())
        }
    }
    
    @Sendable
    func postWithID(req: Request) async throws -> HTMLResponse {
        try await withContainer(container) {
            guard let blogIDString = req.parameters.get("blogID"),
                  let blogID = UUID(uuidString: blogIDString),
                  let post = try await BlogPost.query(on: req.db).filter(\._$id == blogID).with(\.$author).with(\.$tags).first() else {
                throw Abort(.notFound)
            }
            let canEditBlogPost = try await openFGAService.checkAuthorization(
                client: req.client,
                .init(user: req.auth.userTypeTuple, relation: .can_edit, object: post)
            )
            try await req.ensureUser(.can_view, object: post)
            return try HTMLResponse {
                PostDetail(blog: try post.toViewBlogPost())
                    .environment(user: req.auth.get(User.self), canEditBlogPost: canEditBlogPost)
            }
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
