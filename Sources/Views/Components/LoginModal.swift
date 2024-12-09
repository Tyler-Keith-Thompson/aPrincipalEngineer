//
//  LoginModal.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Elementary

public struct LoginModal: HTML, Sendable {
    public init() { }
    
    public var content: some HTML {
        Modal(closeID: "login-modal") {
            p(.custom(name: "align", value: "center")) { "Login or Sign Up" }
        } body: {
            form(.id("signInForm")) {
                button(.type(.submit)) {
                    img(.src("/images/person.badge.key.fill.svg"), .alt("passkey icon"))
                    " Sign in with Passkey"
                }
            }
            
            form(.id("createAccountForm")) {
                fieldset(.class("row-fluid")) {
                    input(.id("username"),
                          .type(.email),
                          .name("email"),
                          .placeholder("Enter your email"),
                          .autocomplete("email"),
                          .class("col-8"))
                    input(.type(.submit), .value("Sign Up"), .class("col-4"))
                }
            }
        }
    }
}
