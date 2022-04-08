//
//  BlogHighlights.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Publish
import Plot
import Foundation

final class BlogHighlights: Component {
    let items: [Item<APrincipalEngineer>]

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

    init(items: [Item<APrincipalEngineer>]) {
        self.items = items
    }

    var body: Component {
        Element(name: "section") {
            Div {
                Div {
                    H1("Our latest posts and rants.")
                }.class("twelve columns align-center")
            }.class("row")
            Div {
                ComponentGroup(members: self.items.map { item in
                    Article {
                        Div {
                            Div {
                                Link(url: "\(item.path)/index.html") { Element(name: "i") { }.class("fa fa-link") }
                            }.class("permalink")
                            Div {
                                H3 { Link(item.title, url: "\(item.path)/index.html") }
                            }.class("ten columns entry-title pull-right")
                            Div {
                                Paragraph {
                                    Element(name: "time") {
                                        Text(self.visibleDateFormatter.string(from: item.date))
                                    }.attribute(named: "datetime", value: self.timeElementDateFormatter.string(from: item.date))
                                        .class("post-date")
                                    Span("By \(item.metadata.author)")
                                        .class("dauthor")
                                }
                            }.class("two columns post-meta end")
                        }.class("entry-header")
                        Div {
                            Paragraph {
                                Text(item.description)
                                Link(url: "\(item.path)/index.html") { Element(name: "i") { }.class("fa fa-arrow-circle-o-right") }.class("more-link")
                            }
                        }.class("ten columns offset-2 post-content")
                    }.class("row entry")
                })
            }.class("blog-entries")
        }.id("journal")
    }
}
