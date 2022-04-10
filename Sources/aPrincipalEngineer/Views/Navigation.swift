//
//  File.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Plot
import Publish

@available(macOS 10.12, *)
struct SiteNavigation: Component {
    let context: PublishingContext<APrincipalEngineer>
    let page: SitePageProtocol

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
                                Link("Home", url: context.site.url.appendingPathComponent("index.html").absoluteString)
                            }.class(page.path == "index.html" ? "current" : "")
                            ListItem {
                                Link("Blog", url: context.site.url.appendingPathComponent("blog").appendingPathComponent("index.html").absoluteString)
                            }.class(page.path == "blog.html" ? "current" : "")
                            ListItem { Link("About", url: context.site.url.appendingPathComponent("about").appendingPathComponent("index.html").absoluteString) }.class(page.path == "about.html" ? "current" : "")
//                            ListItem { Link("Contact", url: context.site.url.appendingPathComponent("contact").appendingPathComponent("index.html").absoluteString) }.class(page.path == "contact.html" ? "current" : "")
                        }.id("nav")
                            .class("nav")
                    }.id("nav-wrap")
                }.class("twelve columns")
            }.class("row")
        }
    }
}
