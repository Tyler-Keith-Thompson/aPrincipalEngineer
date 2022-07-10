//
//  SparrowTheme.swift
//  
//
//  Created by Tyler Thompson on 1/3/22.
//

import Publish
import Plot
import Foundation

extension Theme where Site == APrincipalEngineer {
    static var sparrow: Self {
        Theme(htmlFactory: SparrowHTMLFactory())
    }

    private struct SparrowHTMLFactory: HTMLFactory {
        func makeIndexHTML(for index: Index, context: PublishingContext<APrincipalEngineer>) throws -> HTML {
            IndexHTML(index: index, context: context).html
        }

        func makeSectionHTML(for section: Section<APrincipalEngineer>, context: PublishingContext<APrincipalEngineer>) throws -> HTML {
            switch section.id {
                case .blog: return Blog(context: context, section: section).html
                case .about: return About(context: context, section: section).html
                case .subscribe: return Subscribe(context: context, section: section).html
            }
        }

        func makeItemHTML(for item: Item<APrincipalEngineer>, context: PublishingContext<APrincipalEngineer>) throws -> HTML {
            Post(context: context, post: item).html
        }

        func makePageHTML(for page: Page,
                          context: PublishingContext<Site>) throws -> HTML {
            HTML(.raw(page.content.body.html))
        }

        func makeTagListHTML(for page: TagListPage,
                             context: PublishingContext<Site>) throws -> HTML? {
            SitePage(sitePage: page,
                     context: context) {
                Div {
                    Div {
                        H1("Browse all tags")
                        List(page.tags.sorted()) { tag in
                            ListItem {
                                Link(tag.string,
                                     url: context.site.url.appendingPathComponent(context.site.path(for: tag).absoluteString).appendingPathComponent("index.html").absoluteString
                                )
                            }
                            .class("tag")
                        }
                        .class("all-tags")
                    }.id("page-content")
                        .class("row")
                }.class("content-outer")
            }.html
        }

        func makeTagDetailsHTML(for page: TagDetailsPage,
                                context: PublishingContext<Site>) throws -> HTML? {
            let visibleDateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, yyyy"
                return formatter
            }()

            let timeElementDateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-dd-MM"
                return formatter
            }()
            return SitePage(sitePage: page,
                            context: context) {
                Div {
                    Div {
                        Div {
                            let components: [Component] = context
                                                            .items(taggedWith: page.tag, sortedBy: \.date, order: .descending)
                                                            .map { post in
                                Article {
                                    Div {
                                        Link(url: context.site.url.appendingPathComponent(post.path.absoluteString).appendingPathComponent("index.html").absoluteString) {
                                            H1(post.title)
                                        }
                                        Paragraph {
                                            Element(name: "time") {
                                                Text(visibleDateFormatter.string(from: post.date))
                                            }.attribute(named: "datetime", value: timeElementDateFormatter.string(from: post.date))
                                                .class("date")
                                            if !post.tags.isEmpty {
                                                Text(" / ")
                                                Span {
                                                    let breadcrumbs: [Component] = post.tags.flatMap { [Link($0.string, url: context.site.url.appendingPathComponent("tags").appendingPathComponent($0.string).appendingPathComponent("index.html").absoluteString), Text(" / ")] as [Component] }.dropLast()
                                                    ComponentGroup(members: breadcrumbs)
                                                }.class("categories")
                                            }
                                        }.class("post-meta")
                                    }.class("entry-header cf")
                                    if let imagePath = post.imagePath {
                                        Div {
                                            Image(url: context.site.url.appendingPathComponent("images").appendingPathComponent(imagePath.absoluteString), description: "post-image")
                                        }.class("post-thumb")
                                    }
                                    Div {
                                        Paragraph(post.description)
                                    }.class("post-content")
                                }.class("post")
                            }
                            ComponentGroup(members: components)
                        }.id("primary")
                            .class("eight columns")
                        Div {
                            Element(name: "aside") {
                                Link("Browse all tags",
                                     url: context.site.url.appendingPathComponent(context.site.tagListPath.absoluteString).appendingPathComponent("index.html").absoluteString
                                )
                                    .class("browse-all")
                            }.id("sidebar")
                        }.id("secondary")
                            .class("four columns end")
                    }.id("page-content")
                        .class("row")
                }.class("content-outer")
            }.html
        }
    }
}
