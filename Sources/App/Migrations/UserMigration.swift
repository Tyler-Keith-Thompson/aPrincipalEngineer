//
//  UserMigration.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Fluent
import Vapor
import Email

extension User {
    struct Migration: AsyncMigration {
        var name: String { "CreateUser" }

        func prepare(on database: Database) async throws {
            try await database.schema("users")
                .id()
                .field("email", .string, .required)
                .field("validated_email", .bool, .required)
                .field("created_at", .datetime, .required)
                .unique(on: "email")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("users").delete()
        }
    }
    
    #if DEBUG
    struct DebugMigration: AsyncMigration {
        var name: String { "DebugMigration" }
        
        func prepare(on database: Database) async throws {
            let user = try User(id: UUID(uuidString: "6D50873A-D6EE-4B1E-9ADF-99067B2B4467"),
                                email: Email("tyler.keith.thompson+passkeylocaltest@gmail.com"),
                                validatedEmail: false)
            try await user.save(on: database)
            let credential = WebAuthnCredential(id: "VfrKvdUqPyotvphVUe4Xe87pTGw=",
                                                publicKey: "pQECAyYgASFYIHHrXineIuM-1AXkvEHfNhaip-TOfJsxP16t7jx24tstIlgg2x-hMNs80pxUyBeMo6J-7zbAt5FmVBrrZRyWlZsdfXA",
                                                currentSignCount: 0, userID: try user.requireID())
            try await credential.save(on: database)
        }
        
        func revert(on database: any Database) async throws { }
    }
    #endif
}
