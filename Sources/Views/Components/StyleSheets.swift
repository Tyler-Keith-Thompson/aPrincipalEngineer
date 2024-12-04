//
//  StyleSheets.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary

struct StyleSheets: HTML {
    var content: some HTML {
        HTMLComment("CSS")
        
        // https://picocss.com/docs
        // https://github.com/Yohn/PicoCSS?tab=readme-ov-file
        // https://yohn.github.io/PicoCSS/
        link(.href("/styles/.pico.min.css"), .rel(.stylesheet))
        link(.href("/styles/modal.css"), .rel(.stylesheet))
        link(.href("/styles/highlight.min.css"), .rel(.stylesheet))
        link(.href("/styles/github-dark.css"), .init(name: "media", value: "(prefers-color-scheme: dark)"), .rel(.stylesheet))
        link(.href("/styles/github.css"), .init(name: "media", value: "(prefers-color-scheme: light), (prefers-color-scheme: no-preference)"), .rel(.stylesheet))
    }
}
