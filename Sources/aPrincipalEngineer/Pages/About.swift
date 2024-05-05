//
//  About.swift
//  
//
//  Created by Tyler Thompson on 4/9/22.
//

import Foundation
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
                        H1("About")
                        Paragraph("A Principal Engineer was created to give tips and advice to those seeking to grow as Software Engineers. As I look back on my career and reflect on how I have suceeded I decided it's time to share that with anybody who is interested. The blog is full of opinions and experiences very much colored by my life, but it's all stuff I wish I could've told myself starting out.")
                    }.class("ten columns centered text-center")
                }.class("row")
            }.id("page-title")
            Div {
                Div {
                    Element(name: "section") {
                        H1("About the Author").class("twelve columns")
                        AuthorSection(author: .tylerThompson, context: context)
                    }.flowRoot()
                    Element(name: "section") {
                        H1("Other Contributors").class("twelve columns")
                        AuthorSection(author: .annaliseMariottini, context: context)
                    }.flowRoot()
                }.id("page-content")
                    .class("row page")
            }.class("content-outer")
        }.html
    }
}

private struct AuthorSection: Component {
    let author: Author
    let context: PublishingContext<APrincipalEngineer>

    var body: Component {
        Div {
            Div {
                Div {
                    Image(url: context.site.url.appendingPathComponent("images").appendingPathComponent(author.image), description: "post-image")
                }.class("gravatar")
                Div {
                    H2(author.name)
                    author.bio
                }.class("about")
            }.class("bio cf")
                .class("eight columns")
            Aside {
                Div {
                    H5("Social")
                    Paragraph {
                        author.socialMedia.map(SocialMediaComponent.init).joined(separator: Node.br())
                    }
                }.class("widget widget_contact")
            }.id("sidebar")
                .class("four columns")
        }.class("post")
    }
}

private struct SocialMediaComponent: Component {
    let socialMedia: SocialMedia

    var body: Component {
        ComponentGroup {
            Text("\(socialMedia.site.rawValue): ")
            Link(socialMedia.title, url: socialMedia.url).linkTarget(.blank)
        }
    }
}

extension Component {
    /// Creates a new block formatting context with the `flow-root` display value.
    ///
    /// This is useful for creating a new block that contains floats.
    fileprivate func flowRoot() -> any Component {
        style("display: flow-root")
    }
}
