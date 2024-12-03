//
//  Index.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary

public struct Index: HTML, Sendable {    
    public init() { }
    
    public var content: some HTML {
        DefaultContent(title: "Home") {
            Markdown(markdown: """
            # Vapor Demo

            This is a demonstration website built using [Vapor](https://vapor.codes/), showcasing a modern, minimalistic web application architecture. The site is unique in that it avoids traditional HTML, CSS, and JavaScript files, relying instead on server-side Swift to generate the entire frontend.

            ## Features

            - **WebAuthn for Registration and Login**  
              Secure, passwordless authentication is implemented using the WebAuthn protocol. Users can register and log in with their hardware security keys or platform authenticators.

            - **Dynamic Interactions with HTMX**  
              The site leverages [HTMX](https://htmx.org/) to enable dynamic interactions, such as form submissions and modal updates, without requiring client-side JavaScript.

            - **Swift-Driven Frontend**  
              The entire frontend is generated server-side using Swift, eliminating the need for traditional HTML, CSS, or JavaScript. This approach keeps the codebase unified and simplifies development.

            ## Why This Demo?

            This project demonstrates how modern web applications can be built with minimal reliance on conventional frontend technologies while leveraging cutting-edge standards like WebAuthn and progressive enhancement with HTMX.

            """)
        }
    }
}
