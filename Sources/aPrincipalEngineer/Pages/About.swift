//
//  About.swift
//  
//
//  Created by Tyler Thompson on 4/9/22.
//

import Plot
import Publish

struct About: SitePageProtocol {
    let context: PublishingContext<APrincipalEngineer>
    let section: Section<APrincipalEngineer>

    var html: HTML {
        SitePage(sitePage: section,
                 context: context) {
            Div {
                Div {
                    Div {
                        H1("About Us")
                        Paragraph("A Principal Engineer was created to give tips and advice to those seeking to grow as Software Engineers. As I look back on my career and reflect on how I have suceeded I decided it's time to share that with anybody who is interested. The blog is full of opinions and experiences very much colored by my life, but it's all stuff I wish I could've told myself starting out.")
                    }.class("ten columns centered text-center")
                }.class("row")
            }.id("page-title")
            Div {
                Div {
                    Div {
                        Element(name: "section") {
                            Div {
                                Div {
                                    Image(url: self.context.site.url.appendingPathComponent("images").appendingPathComponent("tyler-thompson.png"), description: "post-image")
                                }.class("gravatar")
                                Div {
                                    H1("About the author")

                                    Author.tylerThompson.bio
                                }.class("about")
                            }.class("bio cf")
                        }
                    }.id("primary")
                        .class("eight columns post")
                    Div {
                        Aside {
                            TextWidget(title: "Text Widget", text: "Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor, nisi elit consequat ipsum, nec sagittis sem nibh id elit. Duis sed odio sit amet nibh vulputate cursus a sit amet mauris. Morbi accumsan ipsum velit")
                            Div {
                                H5("Social")
                                Paragraph {
                                    Text("LinkedIn: ")
                                    Link("Tyler K. Thompson", url: "https://www.linkedin.com/in/tyler-k-thompson/").linkTarget(.blank)
                                }
                            }.class("widget widget_contact")
                        }.id("sidebar")
                    }.id("secondary")
                        .class("four columns end")
                }.id("page-content")
                    .class("row page")
            }.class("content-outer")
        }.html
    }
}
