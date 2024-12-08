//
//  BlogPost.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Fluent
import Vapor
import Views

final class BlogPost: Model, Content, @unchecked Sendable {
    static let schema = "blog_posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Enum(key: "status")
    var status: Status

    @Field(key: "title")
    var title: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @OptionalField(key: "published_at")
    var publishedAt: Date?
    
    @Field(key: "description")
    var description: String

    @Field(key: "content")
    var content: String

    @OptionalParent(key: "user_id")
    var author: User?
    
    @Siblings(through: BlogPostTag.self, from: \.$blogPost, to: \.$tag)
    var tags: [Tag]
    
    init() {}
    
    init(id: UUID? = nil, status: Status = .draft, title: String, createdAt: Date? = nil, description: String, content: String, author: User) {
        self.id = id
        self.status = status
        self.title = title
        if let createdAt {
            _createdAt = .init(key: "created_at", on: .none)
            self.createdAt = createdAt
        }
        self.description = description
        self.content = content
        self.$author.id = author.id
    }
}

extension BlogPost {
    enum Status: String, Codable, CaseIterable {
        case draft
        case review
        case published
    }
}

extension BlogPost {
    func toViewBlogPost() throws -> Views.BlogPost {
        try Views.BlogPost(id: requireID().uuidString,
                           tags: tags.map(\.canonicalTitle),
                           title: title,
                           createdAt: createdAt,
                           author: author?.toViewUser(isLoggedIn: false),
                           description: description,
                           content: content)
    }
}

extension BlogPost: OpenFGAModel {
    enum Relation: String {
        case system
        case author
        case viewer
        case can_author
        case can_edit
        case can_review
        case can_view
    }
}
