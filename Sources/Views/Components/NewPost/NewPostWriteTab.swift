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
    
    public var content: some HTML {
        form(.action("/blog/new_post/web_publish"), .method(.post), .id("new_post"), .hx.target("this"), .hx.swap(.outerHTML)) {
            div(.init(name: "role", value: "group")) {
                button(.init(name: "aria-current", value: "true")) { "Write" }
                button(.hx.post("/views/new_post/preview"), .hx.vals("{\"csrfToken\": \"\(csrfToken)\"}"), .hx.include("[name='post_title'], [name='post_tags'], [name='post_content'], [name='post_description']"), .class("secondary")) { "Preview" }
            }
            "Title: "; input(.name("post_title"), .id("post_title"), .placeholder("A short title for your post"), .value(title))
            "Tags: "; input(.name("post_tags"), .id("post_tags"), .placeholder("Space separated list of tags (WARNING: No autocomplete yet, don't duplicate tags)"), .value(tags.joined(separator: " ")))
            textarea(
                .name("post_description"),
                .id("post_description"),
                .placeholder("Write a short paragraph to describe your post"),
                .init(name: "aria-label", value: "Post Description")
            ) { description }
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
