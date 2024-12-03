//
//  ViewController.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Vapor
import Elementary
import VaporElementary
import Views

struct ViewController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let routes = routes.grouped("views")
        routes.get("close-modal", use: self.emptyView)
        routes.get("login-modal", use: self.loginModal)
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
