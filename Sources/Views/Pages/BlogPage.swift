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
                    h1 { blog.title }
                    span {
                        strong { blog.createdAt.flatMap { $0.formatted(date: .abbreviated, time: .omitted) + " " } ?? "" }
                        for tag in blog.tags {
                            strong { "/ " }
                            tag
                            " "
                        }
                    }
                    p { blog.description }
                    hr()
                }
            }
        }
    }
}
