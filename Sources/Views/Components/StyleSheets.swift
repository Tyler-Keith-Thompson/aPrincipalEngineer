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
        link(.href("/styles/site.css"), .rel(.stylesheet))
        link(.href("/styles/prism.css"), .rel(.stylesheet))
    }
}
