//
//  Markdown.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary
import Ink

struct Markdown: HTML {
    let markdown: String
    var content: some HTML {
        HTMLRaw(MarkdownParser().html(from: markdown))
    }
}
