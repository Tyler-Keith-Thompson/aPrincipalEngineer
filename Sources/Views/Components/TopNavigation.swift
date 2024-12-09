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
        nav {
            ul {
                li {  a(.href("/")) { strong { "A Principal Engineer" } } }
            }
            ul {
                li { a(.href("/authors")) { "Authors" } }
                li { a(.href("/blog")) { "Blog" } }
                if user.isLoggedIn {
                    li { button(.hx.post("/users/logout"), .class("secondary")) { "Logout" } }
                } else {
                    li { button(.hx.get("/views/login-modal"), .hx.target("#login-modal"), .hx.swap(.innerHTML), .class("secondary")) { "Login" } }
                }
            }
        }
        div(.id("login-modal")) { }
    }
}
