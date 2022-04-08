//
//  File.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Plot

struct SiteNavigation: Component {
    let page: SitePage
    init(for page: SitePage) {
        self.page = page
    }

    var body: Component {
        Header {
            Div {
                Div {
                    Div {
                        Link(url: "index.html") {
                            H2("A Principal Engineer")
                        }
                    }.class("logo")
                    Navigation {
                        Link("Show navigation", url: "#nav-wrap")
                            .class("mobile-btn")
                            .attribute(named: "title", value: "Show navigation")
                        Link("Hide navigation", url: "#")
                            .class("mobile-btn")
                            .attribute(named: "title", value: "Hide navigation")

                        List {
                            ListItem {
                                Link("Home", url: "index.html")
                            }.class(page.path == "index.html" ? "current" : "")
                            ListItem {
                                Span {
                                    Link("Blog", url: "blog.html")
                                }
                                List {
                                    ListItem {
                                        Link("Blog Index", url: "blog.html")
                                        Link("Post", url: "single.html")
                                    }
                                }.id("nav")
                                    .class("nav")
                            }.class(page.path == "blog.html" ? "current" : "")
                            ListItem { Link("About", url: "about.html") }.class(page.path == "about.html" ? "current" : "")
                            ListItem { Link("Contact", url: "contact.html") }.class(page.path == "contact.html" ? "current" : "")
                        }.id("nav")
                            .class("nav")
                    }.id("nav-wrap")
                }.class("twelve columns")
            }.class("row")
        }
    }
}
