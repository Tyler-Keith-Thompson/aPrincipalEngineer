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
            .grouped(CSRFMiddleware())
        protected.post("new_post", "write", use: self.newPostWriteTab)
        protected.post("new_post", "preview", use: self.newPostPreviewTab)
    }
    
    @Sendable func newPostPreviewTab(req: Request) async throws -> HTMLResponse {
        let markdown = try req.content.get(String.self, at: "post_content")
        return HTMLResponse {
            NewPostPreviewTab(postMarkdown: markdown)
                .environment(user: req.auth.get(User.self))
                .environment(csrfToken: req.csrf.storeToken())
        }
    }
    
    @Sendable func newPostWriteTab(req: Request) async throws -> HTMLResponse {
        let markdown = try req.content.get(String.self, at: "post_content")
        return HTMLResponse {
            NewPostWriteTab(postMarkdown: markdown)
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
