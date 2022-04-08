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
                        Slide(title: "Free amazing site template",
                              content: "Aenean condimentum, lacus sit amet luctus lobortis, dolores et quas molestias excepturi enim tellus ultrices elit, amet consequat enim elit noneas sit amet luctu. lacus sit amet luctus lobortis, dolores et quas molestias excepturi enim tellus ultrices elit.",
                              image: Image("images/sliders/home-slider-image-01.png"))
                    }
                    ListItem {
                        Slide(title: "Responsive + HTML5 + CSS3",
                              content: "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti eos et accusamus. amet consequat enim elit noneas sit amet luctu. lacus sit amet luctus lobortis. Aenean condimentum, lacus sit amet luctus.",
                              image: Image("images/sliders/home-slider-image-02.png"))
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
