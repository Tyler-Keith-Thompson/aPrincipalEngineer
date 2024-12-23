//
//  UserBearerAuthenticator.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import JWT
import Vapor
import DependencyInjection

struct UserBearerAuthenticator: AsyncBearerAuthenticator {
    typealias User = App.User
    @Injected(Container.userAuthenticatorKeyStore) private var keyStore
    let container = Container.current

    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        await withContainer(container) {
            do {
                let keyStore = Container.userAuthenticatorKeyStore()
                let verifiedPayload: AccessToken = try await keyStore.verify(bearer.token, as: AccessToken.self)
                let userID = try await verifiedPayload.userID(cache: request.cache)
                guard let user = try await User.find(userID, on: request.db) else {
                    throw JWTError.generic(identifier: "user-not-found", reason: "User not found")
                }
                if let clientID = verifiedPayload.aud.value.first {
                    let revoked = try await request.cache.get(.accessTokenRevokedKey(for: userID.uuidString, clientID: clientID), as: Bool.self)
                    if let revokedToken = revoked, revokedToken {
                        throw JWTError.generic(identifier: "token-revoked", reason: "This token has been revoked")
                    }
                }
                request.auth.login(user)
            } catch {
                request.logger.error("Error authenticating user: \(error)")
            }
        }
    }
}

extension Container {
    static let userAuthenticatorKeyStore = Factory(scope: .cached) {
        JWTKeyCollection()
    }
}
