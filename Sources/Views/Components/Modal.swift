//
//  Modal.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Elementary
import ElementaryHTMX

struct Modal<Head: HTML, Body: HTML>: HTML {
    let closeID: String
    var _head: Head?
    let _body: Body
    var content: some HTML {
        div(.hx.swapOOB(.afterBegin, "html")) {
            div(.hx.ext(.classTools), .init(name: "apply-parent-classes", value: "add modal-is-opening & add modal-is-open")) { }
        }
        div(.id("modal-container"), .style("visibility: hidden;")) {
            dialog(.init(name: "open", value: nil)) {
                article {
                    header {
                        button(.custom(name: "aria-label", value: "Close"),
                               .rel("prev"),
                               .hx.get("/views/close-modal"),
                               .hx.target("#\(closeID)"),
                               .hx.swap(.init(rawValue: "innerHTML swap:0.3s"))) { }
                        _head
                    }
                    _body
                }
            }
        }
    }
    
    init(closeID: String, @HTMLBuilder head: () -> Head, @HTMLBuilder body: () -> Body) {
        self.closeID = closeID
        _head = head()
        _body = body()
    }
    
    init(closeID: String, @HTMLBuilder body: () -> Body) where Head == Never {
        self.closeID = closeID
        _body = body()
    }
}
