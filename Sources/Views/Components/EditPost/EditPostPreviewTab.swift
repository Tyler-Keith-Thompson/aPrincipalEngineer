//
//  EditPostPreviewTab.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/8/24.
//

import Foundation
import Elementary
import ElementaryHTMX

public struct EditPostPreviewTab: HTML, Sendable {
    @Environment(EnvironmentValue.$user) private var user
    @Environment(EnvironmentValue.$csrfToken) private var csrfToken

    let post: BlogPost
    
    public init(post: BlogPost) {
        self.post = post
    }
    
    var postData: PostData {
        PostData(csrfToken: csrfToken,
                 post_id: post.id,
                 post_title: post.title,
                 post_tags: post.tags.joined(separator: " "),
                 post_description: post.description,
                 post_content: post.content)
    }
    
    public var content: some HTML {
        form(.action("/blog/edit_post/web_update"), .method(.post), .id("edit_post"), .hx.target("this"), .hx.swap(.outerHTML)) {
            div(.init(name: "role", value: "group")) {
                button(
                    .class("secondary"),
                    .hx.post("/views/edit_post/write"),
                    .hx.vals((try? JSONEncoder().encode(postData)).flatMap { String(data: $0, encoding: .utf8) } ?? "")
                ) { "Write" }
                button(.init(name: "aria-current", value: "true")) { "Preview" }
            }
            article {
                PostDetail(blog: BlogPost(id: post.id,
                                          tags: post.tags,
                                          title: post.title,
                                          createdAt: post.createdAt,
                                          author: user,
                                          description: post.description,
                                          content: post.content))
            }
            input(.type(.hidden), .name("post_id"), .value(post.id))
            input(.type(.hidden), .name("post_title"), .value(post.title))
            input(.type(.hidden), .name("post_tags"), .value(post.tags.joined(separator: " ")))
            input(.type(.hidden), .name("post_description"), .value(post.description))
            input(.type(.hidden), .name("post_content"), .value(post.content))
            input(.type(.hidden), .name("csrfToken"), .value(csrfToken))
            button(.type(.submit)) {
                "Publish"
            }
            script { "Prism.highlightAll();" }
        }
    }
}

extension EditPostPreviewTab {
    struct PostData: Codable {
        let csrfToken: String
        let post_id: String
        let post_title: String
        let post_tags: String
        let post_description: String
        let post_content: String
    }
}
