//
//  EditPostPage.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/8/24.
//

import Elementary
import ElementaryHTMX

public struct EditPostPage: HTML, Sendable {
    @Environment(EnvironmentValue.$user) private var user
    
    let post: BlogPost
    public init(post: BlogPost) {
        self.post = post
    }
    
    // half assed rendering for now
    public var content: some HTML {
        AsyncContent {
            DefaultContent(title: "Edit Post") {
                EditPostWriteTab(post: post)
            }
        }
    }
}
