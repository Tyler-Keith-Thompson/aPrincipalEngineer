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
        enum HTMLFactoryError: Error {
            case noHTMLToGenerate
        }

        func makeIndexHTML(for index: Index, context: PublishingContext<APrincipalEngineer>) throws -> HTML {
            IndexHTML(index: index, context: context).html
        }

        func makeSectionHTML(for section: Section<APrincipalEngineer>, context: PublishingContext<APrincipalEngineer>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: section, on: context.site),
                .body {
                    H1("FINDME")
//                    SiteHeader(context: context, selectedSelectionID: section.id)
//                    Wrapper {
                        H1(section.title)
//                        ItemList(items: section.items, site: context.site)
//                    }
                    SiteFooter()
                }
            )
        }

        func makeItemHTML(for item: Item<APrincipalEngineer>, context: PublishingContext<APrincipalEngineer>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: item, on: context.site),
                .body(
                    .class("item-page"),
                    .components {
//                        SiteHeader(context: context, selectedSelectionID: item.sectionID)
//                        Wrapper {
                            Article {
                                Div(item.content.body).class("content")
                                Span("Tagged with: ")
//                                ItemTagList(item: item, site: context.site)
                            }
//                        }
                        SiteFooter()
                    }
                )
            )
//            HTML(
//                .head(for: item, on: context.site),
//                .body(
////                    .ul(
////                        .class("ingredients"),
////                        //                                    .forEach(item.metadata.ingredients) {
////                        //                                        .li(.text($0))
////                        //                                    }
////                    ),
//                    //                                .p(
//                    //                                    "This will take around ",
//                    //                                    "\(Int(item.metadata.preparationTime / 60)) ",
//                    //                                    "minutes to prepare"
//                    //                                ),
//                        .contentBody(item.body)
//                )
//            )
        }

        func makePageHTML(for page: Page,
                          context: PublishingContext<Site>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: page, on: context.site),
                .body {
//                    SiteHeader(context: context, selectedSelectionID: nil)
                    page.body
//                    Wrapper(page.body)
                    SiteFooter()
                }
            )
        }

        func makeTagListHTML(for page: TagListPage,
                             context: PublishingContext<Site>) throws -> HTML? {
            HTML(
                .lang(context.site.language),
                .head(for: page, on: context.site),
                .body {
//                    SiteHeader(context: context, selectedSelectionID: nil)
//                    Wrapper {
                        H1("Browse all tags")
                        List(page.tags.sorted()) { tag in
                            ListItem {
                                Link(tag.string,
                                     url: context.site.path(for: tag).absoluteString
                                )
                            }
                            .class("tag")
                        }
                        .class("all-tags")
//                    }
                    SiteFooter()
                }
            )
        }

        func makeTagDetailsHTML(for page: TagDetailsPage,
                                context: PublishingContext<Site>) throws -> HTML? {
            HTML(
                .lang(context.site.language),
                .head(for: page, on: context.site),
                .body {
//                    SiteHeader(context: context, selectedSelectionID: nil)
//                    Wrapper {
                        H1 {
                            Text("Tagged with ")
                            Span(page.tag.string).class("tag")
                        }

                        Link("Browse all tags",
                            url: context.site.tagListPath.absoluteString
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
                    SiteFooter()
                }
            )
        }
    }
}
