//
//  EditPostWriteTab.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/8/24.
//

import Elementary
import ElementaryHTMX

public struct EditPostWriteTab: HTML, Sendable {
    @Environment(EnvironmentValue.$user) private var user
    @Environment(EnvironmentValue.$csrfToken) private var csrfToken

    let post: BlogPost
    
    public init(post: BlogPost) {
        self.post = post
    }
    
    public var content: some HTML {
        form(.action("/blog/edit_post/web_update"), .method(.post), .id("edit_post"), .hx.target("this"), .hx.swap(.outerHTML)) {
            div(.init(name: "role", value: "group")) {
                button(.init(name: "aria-current", value: "true")) { "Write" }
                button(.hx.post("/views/edit_post/preview"), .hx.vals("{\"csrfToken\": \"\(csrfToken)\"}"), .hx.include("[name='post_title'], [name='post_tags'], [name='post_content'], [name='post_description'], [name='post_id']"), .class("secondary")) { "Preview" }
            }
            "Title: "; input(.name("post_title"), .id("post_title"), .placeholder("A short title for your post"), .value(post.title))
            "Tags: "; input(.name("post_tags"), .id("post_tags"), .placeholder("Space separated list of tags (WARNING: No autocomplete yet, don't duplicate tags)"), .value(post.tags.joined(separator: " ")))
            textarea(
                .name("post_description"),
                .id("post_description"),
                .placeholder("Write a short paragraph to describe your post"),
                .init(name: "aria-label", value: "Post Description")
            ) { post.description }
            textarea(
                .style("height: 500px;"),
                .name("post_content"),
                .id("post_content"),
                .placeholder("Write up your post in markdown..."),
                .init(name: "aria-label", value: "Post Content")
            ) { post.content }
            input(.type(.hidden), .name("post_id"), .value(post.id))
            input(.type(.hidden), .name("csrfToken"), .value(csrfToken))
            button(.type(.submit)) {
                "Publish"
            }
        }
    }
}
