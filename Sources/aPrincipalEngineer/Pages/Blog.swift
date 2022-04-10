//
//  Blog.swift
//  
//
//  Created by Tyler Thompson on 4/9/22.
//

import Foundation
import Plot
import Publish

@available(macOS 12.0, *)
struct Blog: SitePageProtocol {
    let context: PublishingContext<APrincipalEngineer>
    let section: Section<APrincipalEngineer>
    let pageSize: Int
    let offset: Int

    init(context: PublishingContext<APrincipalEngineer>, section: Section<APrincipalEngineer>, pageSize: Int = 10, offset: Int = 0) {
        self.context = context
        self.section = section
        self.pageSize = pageSize
        self.offset = offset
    }

    static var pageTitle: Component {
        PageTitle(title: "Our Blog.", subtitle: "Aenean condimentum, lacus sit amet luctus lobortis, dolores et quas molestias excepturi enim tellus ultrices elit, amet consequat enim elit noneas sit amet luctu.")
    }

    static var visibleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()

    static var timeElementDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-dd-MM"
        return formatter
    }()

    var html: HTML {
        SitePage(sitePage: section,
                 context: context) {
            Self.pageTitle
            let items = context.allItems(sortedBy: \.date, order: .descending)
            Text("Page size: \(pageSize), offset: \(offset)")
            Div {
                Div {
                    Div {
                        let components: [Component] = items.prefix((pageSize * offset) + pageSize).suffix(pageSize).map { post in
                            Article {
                                Div {
                                    H1(post.title)
                                    Paragraph {
                                        Element(name: "time") {
                                            Text(Self.visibleDateFormatter.string(from: post.date))
                                        }.attribute(named: "datetime", value: Self.timeElementDateFormatter.string(from: post.date))
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
                        pagination
                    }.id("primary")
                        .class("eight columns")
                    Div {
                        Element(name: "aside") {
                            Div {
                                H5("Text Widget").class("widget-title")
                                Div {
                                    Text("Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor, nisi elit consequat ipsum, nec sagittis sem nibh id elit. Duis sed odio sit amet nibh vulputate cursus a sit amet mauris. Morbi accumsan ipsum velit")
                                }.class("textwidget")
                            }.class("widget widget_text")

                            Div {
                                H5("Categories").class("widget-title")
                                List {
                                    let tagLinks: [Component] = context.allTags.map { tag in ListItem { Link(tag.string, url: context.site.url.appendingPathComponent("tags").appendingPathComponent(tag.string).appendingPathComponent("index.html").absoluteString) } as Component }
                                    ComponentGroup(members: tagLinks)
                                }.class("link-list cf")
                            }.class("widget widget_categories")

                            Div {
                                H5("Tags").class("widget-title")
                                Div {
                                    let tags: [Component] = items.prefix((pageSize * offset) + pageSize).suffix(pageSize).flatMap(\.tags).map { Link($0.string, url: context.site.url.appendingPathComponent("tags").appendingPathComponent($0.string).appendingPathComponent("index.html").absoluteString) as Component }
                                    ComponentGroup(members: tags)
                                }.class("tagcloud cf")
                            }.class("widget widget_tag_cloud")
                        }.id("sidebar")
                    }.id("secondary")
                        .class("four columns end")
                }.id("page-content")
                    .class("row")
            }.class("content-outer")
        }.html
    }

    var pagination: Component {
        Navigation {
            let items = context.allItems(sortedBy: \.date, order: .descending)
            let currentPage = offset + 1
            let pages = items.count / pageSize
            let paginationLinks: [Component] = (0..<pages).map { pageNumber in
                // add current if we are on the current page
                ListItem {
                    Link(url: context.site.url.appendingPathComponent("pages").appendingPathComponent("\(pageNumber+1)").appendingPathComponent("index.html")) {
                        Span("\(pageNumber+1)").class("page-numbers").class(pageNumber+1 == currentPage ? "current" : "")
                    }
                }
            }
            if paginationLinks.count > 1 {
                List {
                    ListItem {
                        if currentPage == 1 {
                            Span("Prev").class("page-numbers prev inactive")
                        } else {
                            Link(url: context.site.url.appendingPathComponent("pages").appendingPathComponent("\(currentPage-1)").appendingPathComponent("index.html")) {
                                Span("Prev").class("page-numbers prev")
                            }
                        }
                    }
                    ComponentGroup(members: paginationLinks)
                    ListItem {
                        if currentPage == pages {
                            Span("Next").class("page-numbers next inactive")
                        } else {
                            Link(url: context.site.url.appendingPathComponent("pages").appendingPathComponent("\(currentPage+1)").appendingPathComponent("index.html")) {
                                Span("Next").class("page-numbers next")
                            }
                        }
                    }
                }
            }
        }.class("col full pagination")
    }
}