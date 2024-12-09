//
//  BlogSearchPage.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Elementary
import Afluent

public struct BlogSearchPage: HTML, Sendable {
    @Environment(EnvironmentValue.$user) private var user

    let blogs: AnyAsyncSequence<BlogPost>
    
    public init(blogs: AnyAsyncSequence<BlogPost>) {
        self.blogs = blogs
    }
    
    // half assed rendering for now
    public var content: some HTML {
        AsyncContent {
            DefaultContent(title: "Blog") {
                if user.canCreateBlogPost {
                    div(.class("row-fluid")) {
                        a(.init(name: "role", value: "button"), .class("offset-8 offset-xl-9 offset-xxl-10 col-4 col-xl-3 col-xxl-2")) { "New Post" }
                    }
                }
                AsyncForEach(blogs) { blog in
                    BlogHeader(blog: blog)
                    p { blog.description }
                    hr()
                }
            }
        }
    }
}
