//
//  Markdown.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary
import Ink

struct Markdown: HTML {
    var parser: MarkdownParser {
        var parser = MarkdownParser()

        let modifier = Modifier(target: .codeBlocks) { html, markdown in
            let language: String = {
                // Check if it's a fenced code block
                if markdown.hasPrefix("```") {
                    let firstLine = markdown.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true).first ?? ""
                    let identifier = firstLine.drop(while: { $0 == "`" }).trimmingCharacters(in: .whitespaces)
                    return identifier.isEmpty ? "swift" : identifier
                }
                // Default to "swift" for non-fenced blocks
                return "swift"
            }()
            return "<div class=\"language-\(language)\">" + html + "</div>"
        }

        parser.addModifier(modifier)
        return parser
    }
    let markdown: String
    var content: some HTML {
        div(.class("language-swift")) { // will be overriden if a different language is detected, but helpful for inline code snippets
            HTMLRaw(parser.html(from: markdown))
        }
    }
}
