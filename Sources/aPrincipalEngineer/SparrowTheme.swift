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
            HTML()
        }

        func makeItemHTML(for item: Item<APrincipalEngineer>, context: PublishingContext<APrincipalEngineer>) throws -> HTML {
            HTML()
        }

        func makePageHTML(for page: Page, context: PublishingContext<APrincipalEngineer>) throws -> HTML {
            HTML()
        }

        func makeTagListHTML(for page: TagListPage, context: PublishingContext<APrincipalEngineer>) throws -> HTML? {
            HTML()
        }

        func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<APrincipalEngineer>) throws -> HTML? {
            HTML()
        }
    }
}
