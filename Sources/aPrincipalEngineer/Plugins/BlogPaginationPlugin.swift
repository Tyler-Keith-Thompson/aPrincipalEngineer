//
//  BlogPaginationPlugin.swift
//  
//
//  Created by Tyler Thompson on 4/9/22.
//

import Publish
import Plot
import Foundation

@available(macOS 10.12, *)
extension Plugin where Site == APrincipalEngineer {
    static var generatePaginatedBlogPages: Self {
        Plugin(name: "Generated Paginated Blog Pages") { context in
            guard let blogSection = context.sections.first(where: { $0.id.rawValue == APrincipalEngineer.SectionID.blog.rawValue }) else {
                throw PublishingError(
                    infoMessage: "Unable to find blog section"
                )
            }
            let PAGE_SIZE = 10
            let allItems = context.sections.flatMap { $0.items }
            let pages = (0..<allItems.count / PAGE_SIZE).map { i -> Page in
                let index = i + 1
                let blog = Blog(context: context, section: blogSection, pageSize: PAGE_SIZE, offset: PAGE_SIZE * i)
                return Page(path: Path("pages/\(index)"), content: .init(title: "TEST", description: "TEST", body: .init(html: blog.html.render()), date: Date(), lastModified: Date(), imagePath: nil, audio: nil, video: nil))
            }
            pages.forEach {
                context.addPage($0)
            }
        }
    }

    static var ensureAllItemsAreTagged: Self {
        Plugin(name: "Ensure that all items are tagged") { context in
            let allItems = context.sections.flatMap { $0.items }

            for item in allItems {
                guard !item.tags.isEmpty else {
                    throw PublishingError(
                        path: item.path,
                        infoMessage: "Item has no tags"
                    )
                }
            }
        }
    }
}
