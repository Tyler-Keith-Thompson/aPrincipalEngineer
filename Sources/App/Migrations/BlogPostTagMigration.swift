//
//  BlogPostTagMigration.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Fluent

extension BlogPostTag {
    struct Migration: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema(BlogPostTag.schema)
                .id()
                .field("blog_post_id", .uuid, .required, .references(BlogPost.schema, "id", onDelete: .cascade))
                .field("tag_id", .uuid, .required, .references(Tag.schema, "id", onDelete: .cascade))
                .unique(on: "blog_post_id", "tag_id")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(BlogPostTag.schema).delete()
        }
    }
}
