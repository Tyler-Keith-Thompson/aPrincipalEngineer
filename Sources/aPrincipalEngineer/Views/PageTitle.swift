//
//  PageTitle.swift
//  
//
//  Created by Tyler Thompson on 4/9/22.
//

import Publish
import Plot

@available(macOS 10.12, *)
struct PageTitle: Component {
    let title: String
    let subtitle: String

    var body: Component {
        Div {
            Div {
                Div {
                    H1(title)
                    Paragraph(subtitle)
                }.class("ten columns centered text-center")
            }.class("row")
        }.id("page-title")
    }
}
