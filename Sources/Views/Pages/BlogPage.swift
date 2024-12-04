//
//  BlogPage.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Elementary
import Afluent

public struct BlogPage: HTML, Sendable {
    let blogs: AnyAsyncSequence<BlogPost>
    
    public init(blogs: AnyAsyncSequence<BlogPost>) {
        self.blogs = blogs
    }
    
    // half assed rendering for now
    public var content: some HTML {
        AsyncContent {
            DefaultContent(title: "Blog") {
                AsyncForEach(blogs) { blog in
                    p { "tags: \(blog.tags.joined(separator: ", "))" }
                    p { "title: \(blog.title) \(blog.createdAt?.formatted() ?? "")" }
                    p { "author: \(blog.author?.email ?? "unknown")" }
                    p { "description: \(blog.description)" }
                }
            }
        }
    }
}
