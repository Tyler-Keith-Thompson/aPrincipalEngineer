//
//  Post.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Foundation
import Publish
import Plot

final class Post: SitePageProtocol {
    let context: PublishingContext<APrincipalEngineer>
    let post: Item<APrincipalEngineer>

    init(context: PublishingContext<APrincipalEngineer>, post: Item<APrincipalEngineer>) {
        self.context = context
        self.post = post
    }

    lazy var visibleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()

    lazy var timeElementDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-dd-MM"
        return formatter
    }()

    var html: HTML {
        SitePage(sitePage: post,
                 context: context) {
            Blog.pageTitle
            Div {
                Div {
                    Div {
                        Article {
                            Div {
                                H1(self.post.title)
                                Paragraph {
                                    Element(name: "time") {
                                        Text(self.visibleDateFormatter.string(from: self.post.date))
                                    }.attribute(named: "datetime", value: self.timeElementDateFormatter.string(from: self.post.date))
                                        .class("date")
                                    if !self.post.tags.isEmpty {
                                        Text(" / ")
                                        Span {
                                            let breadcrumbs: [Component] = self.post.tags.flatMap { [Link($0.string, url: self.context.site.url.appendingPathComponent("tags").appendingPathComponent($0.string).appendingPathComponent("index.html").absoluteString), Text(" / ")] as [Component] }.dropLast()
                                            ComponentGroup(members: breadcrumbs)
                                        }.class("categories")
                                    }
                                }.class("post-meta")
                            }.class("entry-header cf")
                            if let imagePath = self.post.imagePath {
                                Div {
                                    Image(url: self.context.site.url.appendingPathComponent("images").appendingPathComponent(imagePath.absoluteString), description: "post-image")
                                }.class("post-thumb")
                            }
                            Div {
                                Paragraph(self.post.description).class("lead")
                                self.post.content.body
                                Div {
                                    Div {
                                        Image(url: self.context.site.url.appendingPathComponent("images").appendingPathComponent("tyler-thompson.png"), description: "post-image")
                                    }.class("gravatar")
                                    Div {
                                        H5(self.post.metadata.author.formattedName)
                                        self.post.metadata.author.bio
                                    }.class("about")
                                }.class("bio cf")
                            }.class("post-content")
                        }.class("post")
                        Div { }.id("disqus_thread")
                    }.id("primary")
                        .class("eight columns")
                    Div {
                        Aside {
                            TextWidget(title: "About", text: "A Principal Engineer was created to give tips and advice to those seeking to grow as Software Engineers. As I look back on my career and reflect on how I have suceeded I decided it's time to share that with anybody who is interested. The blog is full of opinions and experiences very much colored by my life, but it's all stuff I wish I could've told myself starting out.")

                            Div {
                                H5("Categories").class("widget-title")
                                List {
                                    let tagLinks: [Component] = self.context.allTags.map { tag in ListItem { Link(tag.string, url: self.context.site.url.appendingPathComponent("tags").appendingPathComponent(tag.string).appendingPathComponent("index.html").absoluteString) } as Component }
                                    ComponentGroup(members: tagLinks)
                                }.class("link-list cf")
                            }.class("widget widget_categories")

                            Div {
                                H5("Tags").class("widget-title")
                                Div {
                                    let tags: [Component] = self.post.tags.map { Link($0.string, url: self.context.site.url.appendingPathComponent("tags").appendingPathComponent($0.string).appendingPathComponent("index.html").absoluteString) as Component }
                                    ComponentGroup(members: tags)
                                }.class("tagcloud cf")
                            }.class("widget widget_tag_cloud")
                        }.id("sidebar")
                    }.id("secondary")
                        .class("four columns end")
                }.id("page-content")
                    .class("row")
            }.class("content-outer")

            ComponentGroup(html: #"""
            <script>
                (function() {
                    var t = document,
                    e = t.createElement("script");
                    e.src = "https://aprincipalengineer.disqus.com/embed.js", e.setAttribute("data-timestamp", +new Date), (t.head || t.body).appendChild(e)
                })();
            </script>
            """#)
        }.html
    }
}
