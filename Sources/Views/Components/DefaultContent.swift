//
//  DefaultContent.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary

struct DefaultContent<Head: HTML, Body: HTML, Footer: HTML>: HTML {
    var title: String
    
    let _head: Head
    let _body: Body
    let footer: Footer

    var content: some HTML {
        // TODO: Add standard footer
        Page(title: title) {
            div(.class("container")) {
                TopNavigation()
            }
            _head
        } body: {
            main(.class("container")) {
                _body
            }
        } footer: {
            footer
        }
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
