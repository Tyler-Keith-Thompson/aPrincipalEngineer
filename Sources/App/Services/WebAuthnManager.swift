//
//  WebAuthnManager.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import DependencyInjection
import Vapor
import WebAuthn

extension Container {
    static let webAuthnManager = Factory {
        WebAuthnManager(
            config: WebAuthnManager.Config(
                relyingPartyID: Environment.get("HOSTING_DOMAIN") ?? "localhost",
                relyingPartyName: Environment.get("FLY_APP_NAME") ?? "aPrincipalEngineer",
                relyingPartyOrigin: Container.hostConfig().hostingURL
            )
        )
    }
}
