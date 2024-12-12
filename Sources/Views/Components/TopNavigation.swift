//
//  TopNavigation.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary
import ElementaryHTMX

struct TopNavigation: HTML {
    @Environment(EnvironmentValue.$user) private var user
    
    var content: some HTML {
        nav(.init(name: "role", value: "navigation"), .init(name: "data-position", value: "start"), .init(name: "data-breakpoint", value: "lg")) {
            ul {
                li { a(.href("/")) { strong { "A Principal Engineer" } } }
            }
            input(.type(.checkbox), .id("menu-btn"))
            label(.for("menu-btn"), .style("font-size: calc(var(--pico-font-size) * 1.5);")) {
                "≡"
            }

            ol(.init(name: "role", value: "list")) {
                li(.init(name: "role", value: "listitem")) { a(.href("/authors")) { "Authors" } }
                li(.init(name: "role", value: "listitem")) { a(.href("/blog")) { "Blog" } }
                if user.isLoggedIn {
                    li(.init(name: "role", value: "listitem")) { button(.hx.post("/users/logout"), .class("secondary")) { "Logout" } }
                } else {
                    li(.init(name: "role", value: "listitem")) { button(.hx.get("/views/login-modal"), .hx.target("#login-modal"), .hx.swap(.innerHTML), .class("secondary")) { "Login" } }
                }
            }
        }
        div(.id("login-modal")) { }
    }
}
