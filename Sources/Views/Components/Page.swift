//
//  Page.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary
import ElementaryHTMX

struct Page<Head: HTML, Body: HTML, Footer: HTML>: HTMLDocument {
    @Environment(EnvironmentValue.$user) private var user

    var title: String
    
    var lang: String { "en" }
    
    let _head: Head
    let _body: Body
    let footer: Footer

    var head: some HTML {
        meta(.charset(.utf8))
        meta(.name(.viewport), .content("width=device-width, initial-scale=1"))
        link(.rel("apple-touch-icon"), .init(name: "sizes", value: "180x180"), .href("/apple-touch-icon.png"))
        link(.rel("icon"), .init(name: "sizes", value: "32x32"), .href("/favicon-32x32.png"))
        link(.rel("icon"), .init(name: "sizes", value: "16x16"), .href("/favicon-16x16.png"))
        link(.rel("manifest"), .href("/site.webmanifest"))
        StyleSheets()
        _head
    }
    
    var body: some HTML {
        _body
        footer
        if !user.isLoggedIn {
            script(.type("application/javascript"), .src("/scripts/base64.js")) { }
            script(.type("application/javascript"), .src("/scripts/utils.js")) { }
            script(.type("application/javascript"), .src("/scripts/signIn.js")) { }
            script(.type("application/javascript"), .src("/scripts/createAccount.js")) { }
        }
        Scripts()
    }
    
    init(title: String, @HTMLBuilder head: () -> Head, @HTMLBuilder body: () -> Body, @HTMLBuilder footer: () -> Footer) {
        self.title = title
        _head = head()
        _body = body()
        self.footer = footer()
    }
    
    init(title: String, @HTMLBuilder body: () -> Body, @HTMLBuilder footer: () -> Footer) where Head == EmptyHTML {
        self.title = title
        _head = EmptyHTML()
        _body = body()
        self.footer = footer()
    }
    
    init(title: String, @HTMLBuilder head: () -> Head, @HTMLBuilder body: () -> Body) where Footer == EmptyHTML {
        self.title = title
        _head = head()
        _body = body()
        footer = EmptyHTML()
    }
    
    init(title: String, @HTMLBuilder body: () -> Body) where Head == EmptyHTML, Footer == EmptyHTML {
        self.title = title
        _head = EmptyHTML()
        _body = body()
        footer = EmptyHTML()
    }
}
