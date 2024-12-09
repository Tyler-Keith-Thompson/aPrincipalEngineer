//
//  IDToken.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import JWT
import Vapor
import DependencyInjection

struct IDToken: JWTPayload {
    let iss: IssuerClaim
    let aud: AudienceClaim
    let exp: ExpirationClaim
    let iat: IssuedAtClaim
    let sub: SubjectClaim
    let email: String?
    let emailVerified: Bool?

    func verify(using _: some JWTAlgorithm) throws {
        try exp.verifyNotExpired()
    }
}

extension IDToken {
    func sign() async throws -> String {
        try await Container.userAuthenticatorKeyStore().sign(self)
    }
}
