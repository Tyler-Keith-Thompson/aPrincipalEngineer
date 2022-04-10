//
//  SparrowTheme.swift
//  
//
//  Created by Tyler Thompson on 1/3/22.
//

import Publish
import Plot

extension Theme where Site == APrincipalEngineer {
    static var sparrow: Self {
        Theme(htmlFactory: SparrowHTMLFactory())
    }

    private struct SparrowHTMLFactory: HTMLFactory {
        func makeIndexHTML(for index: Index, context: PublishingContext<APrincipalEngineer>) throws -> HTML {
            IndexHTML(index: index, context: context).html
        }

        func makeSectionHTML(for section: Section<APrincipalEngineer>, context: PublishingContext<APrincipalEngineer>) throws -> HTML {
            switch section.id {
                case .blog: return Blog(context: context, section: section).html
                case .about: return About(context: context, section: section).html
            }
        }

        func makeItemHTML(for item: Item<APrincipalEngineer>, context: PublishingContext<APrincipalEngineer>) throws -> HTML {
            Post(context: context, post: item).html
        }

        func makePageHTML(for page: Page,
                          context: PublishingContext<Site>) throws -> HTML {
            HTML(.raw(page.content.body.html))
        }

        func makeTagListHTML(for page: TagListPage,
                             context: PublishingContext<Site>) throws -> HTML? {
            SitePage(sitePage: page,
                     context: context) {
                H1("Browse all tags")
                List(page.tags.sorted()) { tag in
                    ListItem {
                        Link(tag.string,
                             url: context.site.url.appendingPathComponent(context.site.path(for: tag).absoluteString).appendingPathComponent("index.html").absoluteString
                        )
                    }
                    .class("tag")
                }
                .class("all-tags")
            }.html
        }

        func makeTagDetailsHTML(for page: TagDetailsPage,
                                context: PublishingContext<Site>) throws -> HTML? {
            SitePage(sitePage: page,
                     context: context) {
                H1 {
                    Text("Tagged with ")
                    Span(page.tag.string).class("tag")
                }

                Link("Browse all tags",
                     url: context.site.url.appendingPathComponent(context.site.tagListPath.absoluteString).appendingPathComponent("index.html").absoluteString
                )
                    .class("browse-all")

                //                        ItemList(
                //                            items: context.items(
                //                                taggedWith: page.tag,
                //                                sortedBy: \.date,
                //                                order: .descending
                //                            ),
                //                            site: context.site
                //                        )
                //                    }
            }.html
        }
    }
}
