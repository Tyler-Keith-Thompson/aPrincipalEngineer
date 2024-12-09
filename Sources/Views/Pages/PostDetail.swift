//
//  BlogPage.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/4/24.
//

import Elementary
import Afluent

public struct PostDetail: HTML, Sendable {
    @Environment(EnvironmentValue.$user) private var user
    let blog: BlogPost
    
    public init(blog: BlogPost) {
        self.blog = blog
    }
    
    public var content: some HTML {
        DefaultContent(title: blog.title) {
            if user.canEditBlogPost {
                div(.class("row-fluid")) {
                    a(
                        .init(name: "role", value: "button"),
                        .class("offset-8 offset-xl-9 offset-xxl-10 col-4 col-xl-3 col-xxl-2"),
                        .href("/blog/edit_post/\(blog.id)")
                    ) { "Edit Post" }
                }
            }
            hgroup {
                BlogHeader(blog: blog)
                p { blog.description }
            }
            
            Markdown(markdown: blog.content)
        }
    }
}
