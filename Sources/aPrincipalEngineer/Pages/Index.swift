//
//  Index.swift
//  
//
//  Created by Tyler Thompson on 1/3/22.
//

import Publish
import Plot

struct IndexHTML: SitePageProtocol {
    let index: Index
    let context: PublishingContext<APrincipalEngineer>

    var path: String { "index.html" }

    init(index: Index, context: PublishingContext<APrincipalEngineer>) {
        self.index = index
        self.context = context
    }

    var html: HTML {
        SitePage(sitePage: self,
                 context: context) {
            SiteIntro()
            Element(name: "section") {
                Div {
                    Div {
                        Div {
                            H2("Opinion Warning!")
                            Paragraph("This blog covers a host of topics that are difficult to objectively measure. You'll find it very opinion heavy, but those opinions are formed from lots of experience.")
                        }.class("columns")
                        Div {
                            H2("Employee Oriented.")
                            Paragraph("There are plenty of blogs catered to businesses. What you'll find here is for employees. If you want to become a senior technical leader then this is the place for you!")
                        }.class("columns")
                        Div {
                            H2("Engineering.")
                            Paragraph("You'll find lots of engineering content. This all comes from personal experience on large and small teams across multiple companies.")
                        }.class("columns s-first")
                        Div {
                            H2("Apple Development.")
                            Paragraph("We love Apple development and the Swift programming language! Expect to see full-stack style swift posts, this isn't just about iOS, this is about an entire ecosystem of which iOS is one part.")
                        }.class("columns s-first")
                    }.class("bgrid-quarters s-bgrid-halves")
                }.class("row")
            }.id("info")
            BlogHighlights(context: context, items: Array(context.allItems(sortedBy: \.date, order: .descending).prefix(5)))
        }.html
    }
}
