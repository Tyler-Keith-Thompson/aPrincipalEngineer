//
//  BlogPostMigration.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Fluent

extension BlogPost {
    struct Migration: AsyncMigration {
        var name: String { "BlogPostMigration" }
        
        func prepare(on database: Database) async throws {
            let statusEnum = try await database.enum("BlogPost.Status")
                .case(BlogPost.Status.draft.rawValue)
                .case(BlogPost.Status.review.rawValue)
                .case(BlogPost.Status.published.rawValue)
                .create()
            
            try await database.schema(BlogPost.schema)
                .id()
                .field("status", statusEnum, .required)
                .field("title", .string, .required)
                .field("created_at", .datetime, .required)
                .field("published_at", .datetime)
                .field("description", .string, .required)
                .field("content", .string, .required)
                .field("user_id", .uuid, .references("users", "id", onDelete: .setNull))
                .create()
        }
        
        func revert(on database: any Database) async throws {
            try await database.schema(BlogPost.schema).delete()
            try await database.enum("BlogPost.Status").delete() // Clean up enums
        }
    }
}
