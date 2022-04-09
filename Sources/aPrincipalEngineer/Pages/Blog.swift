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
            let PAGE_SIZE = Int.max
            let items = context.allItems(sortedBy: \.date, order: .descending)
            Div {
                Div {
                    Div {
                        let components: [Component] = items.prefix(PAGE_SIZE).map { post in
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
                        Navigation {
                            let pages = items.count / PAGE_SIZE
                            let paginationLinks: [Component] = (0..<pages).map { pageNumber in
                                // add current if we are on the current page
                                ListItem {
                                    Span("\(pageNumber+1)").class("page-numbers")
                                }
                            }
                            if paginationLinks.count > 1 {
                                List {
                                    ListItem { Span("Prev").class("page-numbers prev inactive") }
                                    ComponentGroup(members: paginationLinks)
                                    ListItem { Span("Next").class("page-numbers next") }
                                }
                            }
                        }.class("col full pagination")
                    }.id("primary")
                        .class("eight columns")
                    // Aside goes here
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
                                    let tags: [Component] = items.prefix(PAGE_SIZE).flatMap(\.tags).map { Link($0.string, url: context.site.url.appendingPathComponent("tags").appendingPathComponent($0.string).appendingPathComponent("index.html").absoluteString) as Component }
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
}
