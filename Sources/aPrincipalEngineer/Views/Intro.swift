//
//  Intro.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Plot

struct SiteIntro: Component {
    var body: Component {
        Element(name: "section") {
            Div {
                List {
                    ListItem {
                        Slide(title: "A peek into senior technical leadership",
                              content: "Check out our articles on being a senior technical leader. We talk about what it's like at companies of all sizes across multiple industries.",
                              image: Image("images/sliders/Collaboration-On-Whiteboard.jpg"))
                    }
                    ListItem {
                        Slide(title: "General software engineering and Swift language tips",
                              content: "We've got Swift language tips and tricks as well as general software engineering content. How do senior technical leaders view \"good\" code?",
                              image: Image("images/sliders/Working-On-Xcode.jpg"))
                    }
                }.class("slides")
            }.id("intro-slider")
                .class("flexslider")
        }.id("intro")
    }
}

extension SiteIntro {
    struct Slide: Component {
        let title: String
        let content: String
        let image: Image

        var body: Component {
            Div {
                Div {
                    Div {
                        H1(title)
                        Paragraph(content)
                    }.class("slider-text")
                    Div {
                        image
                    }.class("slider-image")
                }.class("twelve columns")
            }.class("row")
        }
    }
}
