//
//  ViewController.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Vapor
import Elementary
import VaporElementary
import VaporCSRF
import Views

struct ViewController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let routes = routes.grouped("views")
        routes.get("close-modal", use: self.emptyView)
        routes.get("login-modal", use: self.loginModal)
        
        let protected = routes
            .grouped(User.sessionAuthenticator())
            .grouped(UserBearerAuthenticator())
            .grouped(User.guardMiddleware())
        
        protected.post("new_post", "write", body: .collect(maxSize: "100kb"), use: self.newPostWriteTab)
        protected.post("new_post", "preview", body: .collect(maxSize: "100kb"), use: self.newPostPreviewTab)
        protected.post("edit_post", "write", body: .collect(maxSize: "100kb"), use: self.editPostWriteTab)
        protected.post("edit_post", "preview", body: .collect(maxSize: "100kb"), use: self.editPostPreviewTab)
    }
    
    struct NewPostPreviewRequest: Content {
        let post_title: String
        let post_tags: String
        let post_description: String
        let post_content: String
    }
    @Sendable func newPostPreviewTab(req: Request) async throws -> HTMLResponse {
        try req.csrf.verifyToken()
        let request = try req.content.decode(NewPostPreviewRequest.self)
        return HTMLResponse {
            NewPostPreviewTab(tags: request.post_tags.components(separatedBy: " "),
                              title: request.post_title,
                              description: request.post_description,
                              postMarkdown: request.post_content)
                .environment(user: req.auth.get(User.self))
                .environment(csrfToken: req.csrf.storeToken())
        }
    }
    
    @Sendable func newPostWriteTab(req: Request) async throws -> HTMLResponse {
        try req.csrf.verifyToken()
        let request = try req.content.decode(NewPostPreviewRequest.self)
        return HTMLResponse {
            NewPostWriteTab(tags: request.post_tags.components(separatedBy: " "),
                            title: request.post_title,
                            description: request.post_description,
                            postMarkdown: request.post_content)
                .environment(user: req.auth.get(User.self))
                .environment(csrfToken: req.csrf.storeToken())
        }
    }
    
    struct EditPostPreviewRequest: Content {
        let post_title: String
        let post_tags: String
        let post_description: String
        let post_content: String
        let post_id: String
        let csrfToken: String
    }
    @Sendable func editPostPreviewTab(req: Request) async throws -> HTMLResponse {
        try req.csrf.verifyToken()
        let request = try req.content.decode(EditPostPreviewRequest.self)
        return HTMLResponse {
            EditPostPreviewTab(post: .init(id: request.post_id,
                                           tags: request.post_tags.components(separatedBy: " ").map { $0.lowercased() },
                                           title: request.post_title,
                                           createdAt: nil,
                                           author: nil,
                                           description: request.post_description,
                                           content: request.post_content))
                .environment(user: req.auth.get(User.self))
                .environment(csrfToken: req.csrf.storeToken())
        }
    }
    
    @Sendable func editPostWriteTab(req: Request) async throws -> HTMLResponse {
        try req.csrf.verifyToken()
        let request = try req.content.decode(EditPostPreviewRequest.self)
        return HTMLResponse {
            EditPostWriteTab(post: .init(id: request.post_id,
                                         tags: request.post_tags.components(separatedBy: " ").map { $0.lowercased() },
                                         title: request.post_title,
                                         createdAt: nil,
                                         author: nil,
                                         description: request.post_description,
                                         content: request.post_content))
                .environment(user: req.auth.get(User.self))
                .environment(csrfToken: req.csrf.storeToken())
        }
    }
    
    @Sendable func emptyView(req: Request) async throws -> HTMLResponse {
        HTMLResponse {
            div(.hx.swapOOB(.beforeEnd, "html")) {
                div(.init(name: "hx-ext", value: "class-tools"), .init(name: "apply-parent-classes", value: "remove modal-is-open, remove modal-is-opening")) { }
            }
        }
    }
    
    @Sendable func loginModal(req: Request) async throws -> HTMLResponse {
        HTMLResponse {
            LoginModal()
        }
    }
}
