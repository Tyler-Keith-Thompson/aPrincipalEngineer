//
//  NewPostWriteTab.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/8/24.
//

import Elementary
import ElementaryHTMX

public struct NewPostWriteTab: HTML, Sendable {
    @Environment(EnvironmentValue.$user) private var user
    @Environment(EnvironmentValue.$csrfToken) private var csrfToken

    let postMarkdown: String
    public init(postMarkdown: String) {
        self.postMarkdown = postMarkdown
    }
    
    public var content: some HTML {
        form(.action("/blog/new_post/web_publish"), .method(.post), .id("new_post"), .hx.target("this"), .hx.swap(.outerHTML)) {
            div(.init(name: "role", value: "group")) {
                button(.init(name: "aria-current", value: "true")) { "Write" }
                button(.hx.post("/views/new_post/preview"), .hx.vals("{\"csrfToken\": \"\(csrfToken)\"}"), .hx.include("[name='post_content']"), .class("secondary")) { "Preview" }
            }
            textarea(
                .style("height: 500px;"),
                .name("post_content"),
                .id("post_content"),
                .placeholder("Write up your post in markdown..."),
                .init(name: "aria-label", value: "Post Content")
            ) { postMarkdown }
            input(.type(.hidden), .name("csrfToken"), .value(csrfToken))
            button(.type(.submit)) {
                "Publish"
            }
        }
    }
}
