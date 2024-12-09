//
//  NewPostPreviewTab.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/8/24.
//

import Foundation
import Elementary
import ElementaryHTMX

public struct NewPostPreviewTab: HTML, Sendable {
    @Environment(EnvironmentValue.$user) private var user
    @Environment(EnvironmentValue.$csrfToken) private var csrfToken

    let tags: [String]
    let title: String
    let description: String
    let postMarkdown: String
    
    public init(tags: [String], title: String, description: String, postMarkdown: String) {
        self.tags = tags
        self.title = title
        self.description = description
        self.postMarkdown = postMarkdown
    }
    
    var postData: PostData {
        PostData(csrfToken: csrfToken, post_content: postMarkdown)
    }
    
    public var content: some HTML {
        form(.action("/blog/new_post/web_publish"), .method(.post), .id("new_post"), .hx.target("this"), .hx.swap(.outerHTML)) {
            div(.init(name: "role", value: "group")) {
                button(
                    .class("secondary"),
                    .hx.post("/views/new_post/write"),
                    .hx.vals((try? JSONEncoder().encode(postData)).flatMap { String(data: $0, encoding: .utf8) } ?? "")
                ) { "Write" }
                button(.init(name: "aria-current", value: "true")) { "Preview" }
            }
            article {
                PostDetail(blog: BlogPost(id: "",
                                          tags: tags,
                                          title: title,
                                          createdAt: Date(),
                                          author: user,
                                          description: description,
                                          content: postMarkdown))
            }
            input(.type(.hidden), .name("post_title"), .value(title))
            input(.type(.hidden), .name("post_tags"), .value(tags.joined(separator: " ")))
            input(.type(.hidden), .name("post_description"), .value(description))
            input(.type(.hidden), .name("post_content"), .value(postMarkdown))
            input(.type(.hidden), .name("csrfToken"), .value(csrfToken))
            button(.type(.submit)) {
                "Publish"
            }
            script { "Prism.highlightAll();" }
        }
    }
}

extension NewPostPreviewTab {
    struct PostData: Codable {
        let csrfToken: String
        let post_content: String
    }
}
