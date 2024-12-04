//
//  BlogPostTag.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Foundation
import Vapor
import Fluent

final class BlogPostTag: Model, Content, @unchecked Sendable {
    static let schema = "blog_post+tag"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "blog_post_id")
    var blogPost: BlogPost

    @Parent(key: "tag_id")
    var tag: Tag

    init() { }

    init(id: UUID? = nil, blogPost: BlogPost, tag: Tag) {
        self.id = id
        self.blogPost = blogPost
        self.tag = tag
    }
}
