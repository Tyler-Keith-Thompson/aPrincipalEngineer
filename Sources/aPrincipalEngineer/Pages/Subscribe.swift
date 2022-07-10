//
//  Subscribe.swift
//  
//
//  Created by Tyler Thompson on 7/10/22.
//

import Plot
import Publish

struct Subscribe: SitePageProtocol {
    let context: PublishingContext<APrincipalEngineer>
    let section: Section<APrincipalEngineer>

    var html: HTML {
        SitePage(sitePage: section,
                 context: context) {
            Div {
                Div {
                    Div {
                        H1("Subscribe")
                        Paragraph("A Principal Engineer supports RSS feeds! Read more about how to subscribe.")
                    }.class("ten columns centered text-center")
                }.class("row")
            }.id("page-title")
            Div {
                Div {
                    Div {
                        Markdown("""
                        To subscribe to all articles, tips and videos via RSS, add the following URL to your feeds:
                        ```
                        https://www.aprincipalengineer.com/feed.rss
                        ```

                        If you have not installed an RSS reader, check out [NetNewsWire](https://netnewswire.com/). It's an excellent, open source choice for both iOS and macOS.
                        """)
                    }.id("primary")
                        .class("eight columns post")
                }.id("page-content")
                    .class("row page")
            }.class("content-outer")
        }.html
    }
}
