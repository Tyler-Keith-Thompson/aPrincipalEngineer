//
//  User.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Fluent
import Foundation
import Vapor
import Email
import WebAuthn
import Views

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: Email
    
    @Field(key: "validated_email")
    var validatedEmail: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Children(for: \.$user)
    var credentials: [WebAuthnCredential]

    init() { }

    init(id: UUID? = nil, email: Email, validatedEmail: Bool) {
        self.id = id
        self.email = email
        self.validatedEmail = validatedEmail
    }
}

extension User: Authenticatable { }

extension User: ModelSessionAuthenticatable { }

extension User {
    func toViewUser(isLoggedIn: Bool) -> Views.User {
        .init(isLoggedIn: isLoggedIn, email: email.mailbox)
    }
}
