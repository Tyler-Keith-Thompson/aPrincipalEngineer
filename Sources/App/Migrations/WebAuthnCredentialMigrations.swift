//
//  WebAuthnCredentialMigrations.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Fluent

extension WebAuthnCredential {
    struct Migration: AsyncMigration {
        var name: String { "CreateWebAuthnCredential" }
        
        func prepare(on database: Database) async throws {
            try await database.schema(WebAuthnCredential.schema)
                .field("id", .string, .identifier(auto: false))
                .field("public_key", .string, .required)
                .field("current_sign_count", .uint32, .required)
                .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
                .unique(on: "id")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("webauth_credentals").delete()
        }
    }
}
