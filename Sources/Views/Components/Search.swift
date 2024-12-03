//
//  Search.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Elementary
import ElementaryHTMX

struct SearchField: HTML {
    let id: String
    let name = "search"
    let placeholder = "Search"
    let post: String
    let trigger: String = "input changed delay:500ms, search"
    let target: String
    let indicator: String = ".htmx-indicator"
    
    var content: some HTML {
        input(
            .type(.search),
            .name(name),
            .placeholder(placeholder),
            .custom(name: "aria-label", value: "Search"),
            .hx.post(post),
            .hx.trigger(HTMLAttributeValue.HTMX.EventTrigger(rawValue: trigger)),
            .hx.target(target),
            .hx.indicator(indicator)
        )
    }
}
