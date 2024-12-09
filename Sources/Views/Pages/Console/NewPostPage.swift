//
//  NewPostPage.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/8/24.
//

import Elementary
import ElementaryHTMX

public struct NewPostPage: HTML, Sendable {
    @Environment(EnvironmentValue.$user) private var user
    @Environment(EnvironmentValue.$csrfToken) private var csrfToken
    
    public init() { }
    
    // half assed rendering for now
    public var content: some HTML {
        AsyncContent {
            DefaultContent(title: "New Post") {
                NewPostWriteTab(tags: [],
                                title: "",
                                description: "",
                                postMarkdown: "")
            }
        }
    }
}
