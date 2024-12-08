//
//  Scripts.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary

struct Scripts: HTML {
    var content: some HTML {
        script(.type("application/javascript"), .src("/scripts/htmx.min.js"), .defer) { }
        script(.type("application/javascript"), .src("/scripts/htmxsse.min.js"), .defer) { }
        script(.type("application/javascript"), .src("/scripts/htmxws.min.js"), .defer) { }
        script(.type("application/javascript"), .src("/scripts/htmx-ext-class-tools.js"), .defer) { }
        script(.type("application/javascript"), .src("/scripts/highlight.min.js"), .id("hljs"), .defer) { }
        script(.type("application/javascript"), .src("/scripts/highlight.swift.min.js"), .defer) { }
        script { "document.querySelector('#hljs').addEventListener('load', function() { hljs.highlightAll(); });" }
    }
}
