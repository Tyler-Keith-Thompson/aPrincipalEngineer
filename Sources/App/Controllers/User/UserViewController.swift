//
//  UserViewController.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/9/24.
//

import Fluent
import Email
import Vapor
import VaporElementary
import WebAuthn
import DependencyInjection
import JWTKit
import SendGridKit
import Views
import Queues

struct UserViewController: RouteCollection, Sendable {
    @Injected(Container.webAuthnManager) private var webAuthnManager
    
    let container = Container.current
    func boot(routes: RoutesBuilder) throws {
        let users = routes
            .grouped("users")
            .grouped(User.sessionAuthenticator())

        users.get("profile", use: self.getProfile)
        users.get("verifyEmail", ":token", use: self.verifyEmail)
    }
    
    @Sendable
    func getProfile(req: Request) async throws -> HTMLResponse {
        let user = try req.auth.require(User.self)
        return HTMLResponse {
            Profile()
                .environment(user: user)
        }
    }

    @Sendable
    func verifyEmail(req: Request) async throws -> HTMLResponse {
        guard let token = req.parameters.get("token") else {
            throw Abort(.unprocessableEntity)
        }
        guard let userID = try await req.cache.get(.emailVerificationTokenToUserKey(for: token), as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let user = try await req.db.transaction { database in
            guard let user = try await database.query(User.self).filter(\.$id == userID).first() else {
                throw Abort(.notFound)
            }
            guard !user.validatedEmail else { return user }
            user.validatedEmail = true
            try await user.update(on: database)
            return user
        }
        try await req.cache.delete(.emailVerificationTokenToUserKey(for: token))
        try await req.cache.delete(.userToEmailVerificationTokenKey(for: userID.uuidString))
        return HTMLResponse {
            EmailVerified(username: user.email.mailbox).environment(user: req.auth.get(User.self))
        }
    }
}
