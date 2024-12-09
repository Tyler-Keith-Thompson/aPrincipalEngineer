//
//  WebAuthnCredential.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Fluent
import Vapor
import WebAuthn

final class WebAuthnCredential: Model, Content, @unchecked Sendable {
    static let schema = "webauthn_credentials"

    @ID(custom: "id", generatedBy: .user)
    var id: String?

    @Field(key: "public_key")
    var publicKey: String

    @Field(key: "current_sign_count")
    var currentSignCount: UInt32

    @Parent(key: "user_id")
    var user: User

    init() {}

    init(id: String, publicKey: String, currentSignCount: UInt32, userID: UUID) {
        self.id = id
        self.publicKey = publicKey
        self.currentSignCount = currentSignCount
        self.$user.id = userID
    }

    convenience init(from credential: Credential, userID: UUID) {
        self.init(
            id: credential.id,
            publicKey: credential.publicKey.base64URLEncodedString().asString(),
            currentSignCount: credential.signCount,
            userID: userID
        )
    }
}
