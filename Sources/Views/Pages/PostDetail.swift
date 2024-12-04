//
//  BlogPage.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/4/24.
//

import Elementary
import Afluent

public struct PostDetail: HTML, Sendable {
    let blog: BlogPost
    
    public init(blog: BlogPost) {
        self.blog = blog
    }
    
    public var content: some HTML {
        DefaultContent(title: blog.title) {
            hgroup {
                BlogHeader(blog: blog)
                p { blog.description }
            }
            
            Markdown(markdown: blog.content)
        }
    }
}
