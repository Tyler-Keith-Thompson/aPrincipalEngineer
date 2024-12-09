//
//  TagMigration.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Fluent

extension Tag {
    struct Migration: AsyncMigration {
        var name: String { "TagMigration" }
        
        func prepare(on database: Database) async throws {
            try await database.schema(Tag.schema)
                .id()
                .field("canonical_title", .string, .required)
                .field("alternatives", .array(of: .string), .required)
                .unique(on: "canonical_title")
                .create()
        }
        
        func revert(on database: any Database) async throws {
            try await database.schema(Tag.schema).delete()
        }
    }
}
