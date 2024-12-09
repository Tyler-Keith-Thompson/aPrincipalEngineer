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
        script(.type("application/javascript"), .src("/scripts/prism.js"), .defer) { }
    }
}
