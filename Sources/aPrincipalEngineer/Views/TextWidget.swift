//
//  TextWidget.swift
//  
//
//  Created by Tyler Thompson on 4/24/22.
//

import Plot
import Publish

struct TextWidget: Component {
    let title: String
    let text: String

    var body: Component {
        Div {
            H5(title).class("widget-title")
            Div {
                Text(text)
            }.class("textwidget")
        }.class("widget widget_text")
    }
}
