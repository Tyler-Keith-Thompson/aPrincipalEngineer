//
//  UserController.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Fluent
import Email
import Vapor
import VaporElementary
import WebAuthn
import DependencyInjection
import JWTKit
import SendGridKit
import Views
import Queues

struct UserController: RouteCollection, Sendable {
    @Injected(Container.webAuthnManager) private var webAuthnManager
    
    let container = Container.current
    func boot(routes: RoutesBuilder) throws {
        let users = routes
            .grouped("users")
        let sessionProtected = users
            .grouped(User.sessionAuthenticator())
        
        sessionProtected.post(use: self.create)
        
        sessionProtected.group("makeCredential") { makeCredential in
            makeCredential.get(use: self.getRegistrationCredential)
            makeCredential.post(use: self.createRegistrationCredential)
            makeCredential.delete(use: self.deleteRegistrationCredential)
        }
        sessionProtected.group("authenticate") { authenticate in
            authenticate.get(use: self.getCredential)
            authenticate.post(use: self.login)
        }
        sessionProtected.get("profile") { req -> HTMLResponse in
            let user = try req.auth.require(User.self)
            return HTMLResponse {
                Profile()
                    .environment(EnvironmentValue.$user, .init(isLoggedIn: true, email: user.email.mailbox))
            }
        }
        
        users.post("logout", use: self.logout)

        let protectedUsers = users
            .grouped(UserBearerAuthenticator())
            .grouped(User.guardMiddleware())
        
        protectedUsers.group(":userID") { user in
            user.get(use: self.getUserDetails)
            user.delete(use: self.delete)
        }
        users.get("verifyEmail", ":token", use: self.verifyEmail)
        protectedUsers.post("refresh", use: self.refresh)
    }

    struct LoginRequest: Decodable {
        let credential: AuthenticationCredential
        let clientID: String
    }
    struct TokenResponse: Content {
        let accessToken: String
        let refreshToken: RefreshToken
        let idToken: String
    }
    @Sendable
    func login(req: Request) async throws -> TokenResponse {
        try await withContainer(container) {
            // Obtain the challenge we stored on the server for this session
            guard let challengeEncoded = req.session.data["authChallenge"],
                  let challenge = Data(base64Encoded: challengeEncoded) else {
                throw Abort(.badRequest, reason: "Missing auth session ID")
            }
            
            // Delete the challenge from the server to prevent attackers from reusing it
            req.session.data["authChallenge"] = nil
            
            let request = try req.content.decode(LoginRequest.self)
            // Decode the credential the client sent us
            let authenticationCredential = request.credential
            
            // find the credential the stranger claims to possess
            guard let credential = try await WebAuthnCredential.query(on: req.db)
                .filter(\.$id == authenticationCredential.id.urlDecoded.asString())
                .with(\.$user)
                .first() else {
                throw Abort(.unauthorized)
            }
            
            // if we found a credential, use the stored public key to verify the challenge
            let verifiedAuthentication = try webAuthnManager.finishAuthentication(
                credential: authenticationCredential,
                expectedChallenge: [UInt8](challenge),
                credentialPublicKey: [UInt8](URLEncodedBase64(credential.publicKey).urlDecoded.decoded!),
                credentialCurrentSignCount: credential.currentSignCount
            )
            
            // if we successfully verified the user, update the sign count
            credential.currentSignCount = verifiedAuthentication.newSignCount
            try await credential.save(on: req.db)
            
            // finally authenticate the user
            req.auth.login(credential.user)
            
            let (accessToken, refreshToken, idToken) = try await createNewTokens(for: credential.user, clientID: request.clientID, cache: req.cache)
            try await verifyEmailIfNecessary(for: credential.user, queue: req.queue, cache: req.cache)
            return try await .init(accessToken: accessToken.sign(),
                                   refreshToken: refreshToken,
                                   idToken: idToken.sign())
        }
    }
    
    @Sendable
    func logout(req: Request) async throws -> Response {
        try await withContainer(container) {
            if let bearer = req.headers.bearerAuthorization {
                let store = Container.userAuthenticatorKeyStore()
                let verifiedPayload: AccessToken = try await store.verify(bearer.token, as: AccessToken.self)
                guard let clientID = verifiedPayload.aud.value.first else {
                    throw Abort(.unauthorized)
                }
                let userID = try await verifiedPayload.userID(cache: req.cache).uuidString
                try await req.cache.set(.accessTokenRevokedKey(for: userID, clientID: clientID), to: true)
                try await req.cache.delete(.refreshTokenKey(for: userID, clientID: clientID))
            }
            
            req.session.destroy()
            req.auth.logout(User.self)
            return Response(status: .ok, headers: ["Hx-Redirect": "/"])
        }
    }
    
    struct RefreshRequest: Content {
        let refreshToken: RefreshToken
    }
    @Sendable
    func refresh(req: Request) async throws -> TokenResponse {
        guard let bearer = req.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        let store = Container.userAuthenticatorKeyStore()
        let verifiedPayload: AccessToken = try await store.verify(bearer.token, as: AccessToken.self)
        let user = try req.auth.require(User.self)
        guard let clientID = verifiedPayload.aud.value.first,
                let validRefreshToken = try await req.cache.get(.refreshTokenKey(for: user.requireID().uuidString, clientID: clientID), as: RefreshToken.self) else {
            throw Abort(.unauthorized)
        }
        
        let request = try req.content.decode(RefreshRequest.self)
        
        guard request.refreshToken == validRefreshToken else {
            throw Abort(.unauthorized)
        }
        
        let (accessToken, refreshToken, idToken) = try await createNewTokens(for: user, clientID: clientID, cache: req.cache)
        return try await .init(accessToken: accessToken.sign(),
                               refreshToken: refreshToken,
                               idToken: idToken.sign())
    }
    
    struct UserDetailsResponse: Content {
        let id: UUID?
        let email: Email
        let validatedEmail: Bool
        let createdAt: Date?
        init(user: User) {
            id = user.id
            email = user.email
            validatedEmail = user.validatedEmail
            createdAt = user.createdAt
        }
    }
    @Sendable
    func getUserDetails(req: Request) async throws -> UserDetailsResponse {
        let user = try req.auth.require(User.self)
        guard user.id != nil, user.id == req.parameters.get("userID") else { throw Abort(.unauthorized) }
        return UserDetailsResponse(user: user)
    }

    struct CreateUserRequest: Content, Validatable {
        var email: Email
        
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .rfcCompliantEmail)
        }
    }
    @Sendable
    func create(req: Request) async throws -> Response {
        try CreateUserRequest.validate(content: req)
        let createRequest = try req.content.decode(CreateUserRequest.self)
        let oldUser = try await User.query(on: req.db).filter(\.$email, .equal, createRequest.email).first()
        guard oldUser == nil else { throw Abort(.badRequest, reason: "Cannot create this user.") }
        let user = User(
            email: createRequest.email,
            validatedEmail: false
        )
        try await user.save(on: req.db)
        try req.session.data["userID"] = user.requireID().uuidString
        req.session.data["email"] = user.email.mailbox

        return req.redirect(to: "users/makeCredential")
    }
    
    struct CreateRegistrationCredentialRequest: Decodable {
        let credential: RegistrationCredential
        let clientID: String
    }
    @Sendable
    func createRegistrationCredential(req: Request) async throws -> TokenResponse {
        try await withContainer(container) {
            guard let idString = req.session.data["userID"],
                  let id = UUID(uuidString: idString),
                  let user = try await User.find(id, on: req.db) else {
                throw Abort(.unauthorized)
            }
            
            // Obtain the challenge we stored on the server for this session
            guard let challengeEncoded = req.session.data["registrationChallenge"],
                  let challenge = Data(base64Encoded: challengeEncoded) else {
                throw Abort(.badRequest, reason: "Missing registration session ID")
            }
            
            // Delete the challenge from the server to prevent attackers from reusing it
            req.session.data["registrationChallenge"] = nil
            
            let request = try req.content.decode(CreateRegistrationCredentialRequest.self)
            
            // Verify the credential the client sent us
            let credential = try await webAuthnManager.finishRegistration(
                challenge: [UInt8](challenge),
                credentialCreationData: request.credential,
                confirmCredentialIDNotRegisteredYet: { credentialID in
                    let existingCredential = try await WebAuthnCredential.query(on: req.db)
                        .filter(\.$id == credentialID)
                        .first()
                    return existingCredential == nil
                }
            )
            
            // If the credential was verified, save it to the database
            try await WebAuthnCredential(from: credential, userID: user.requireID()).save(on: req.db)
            let (accessToken, refreshToken, idToken) = try await createNewTokens(for: user, clientID: request.clientID, cache: req.cache)
            req.auth.login(user)
            try await verifyEmailIfNecessary(for: user, queue: req.queue, cache: req.cache)
            return try await .init(accessToken: accessToken.sign(),
                                   refreshToken: refreshToken,
                                   idToken: idToken.sign())
        }
    }
    
    @Sendable
    func getRegistrationCredential(req: Request) async throws -> PublicKeyCredentialCreationOptions {
        try withContainer(container) {
            guard let idString = req.session.data["userID"],
                  let id = UUID(uuidString: idString),
                  let email = req.session.data["email"] else {
                throw Abort(.unauthorized)
            }
            
            // We can then create the options for the client to create a new credential
            let options = webAuthnManager.beginRegistration(user: PublicKeyCredentialUserEntity(id: [UInt8](id.uuidString.utf8), name: email, displayName: email))
            
            // We need to temporarily store the challenge somewhere safe
            req.session.data["registrationChallenge"] = Data(options.challenge).base64EncodedString()
            
            // Return the options to the client
            return options
        }
    }
    
    @Sendable
    func deleteRegistrationCredential(req: Request) async throws -> HTTPStatus {
        guard let idString = req.session.data["userID"],
              let id = UUID(uuidString: idString),
              let user = try await User.find(id, on: req.db) else {
            throw Abort(.unauthorized)
        }

        try await user.$credentials.load(on: req.db)
        guard user.credentials.isEmpty else { throw Abort(.conflict, reason: "Cannot delete user with existing credentials.") }
        try await user.delete(on: req.db)
        req.session.destroy()
        return .noContent
    }
    
    @Sendable
    func getCredential(req: Request) async throws -> PublicKeyCredentialRequestOptions {
        try withContainer(container) {
            let options = try webAuthnManager.beginAuthentication()
            
            req.session.data["authChallenge"] = Data(options.challenge).base64EncodedString()
            
            return options
        }
    }
    
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        try await user.delete(on: req.db)
        return .noContent
    }
    
    @Sendable
    func verifyEmail(req: Request) async throws -> HTMLResponse {
        guard let token = req.parameters.get("token") else {
            throw Abort(.unprocessableEntity)
        }
        guard let userID = try await req.cache.get(.emailVerificationTokenToUserKey(for: token), as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let user = try await req.db.transaction { database in
            guard let user = try await database.query(User.self).filter(\.$id == userID).first() else {
                throw Abort(.notFound)
            }
            guard !user.validatedEmail else { return user }
            user.validatedEmail = true
            try await user.update(on: database)
            return user
        }
        try await req.cache.delete(.emailVerificationTokenToUserKey(for: token))
        try await req.cache.delete(.userToEmailVerificationTokenKey(for: userID.uuidString))
        return HTMLResponse {
            EmailVerified(username: user.email.mailbox)
        }
    }
    
    private func createNewTokens(for user: User, clientID: String, cache: any Vapor.Cache) async throws -> (accessToken: AccessToken, refreshToken: RefreshToken, idToken: IDToken) {
        let accessToken = try await AccessToken(iss: "aPrincipalEngineer",
                                                aud: .init(value: clientID),
                                                exp: .init(value: Date().addingTimeInterval(Measurement<UnitDuration>(value: 30, unit: .minutes).converted(to: .seconds).value)),
                                                iat: .init(value: Date()),
                                                sub: .init(user: user, clientID: clientID, cache: cache),
                                                email: user.email.mailbox,
                                                emailVerified: user.validatedEmail)
        let refreshToken = RefreshToken()
        let idToken = try await IDToken(iss: "aPrincipalEngineer",
                                        aud: .init(value: clientID),
                                        exp: .init(value: Date().addingTimeInterval(Measurement<UnitDuration>(value: 10, unit: .seconds).value)),
                                        iat: .init(value: Date()),
                                        sub: .init(user: user, clientID: clientID, cache: cache),
                                        email: user.email.mailbox,
                                        emailVerified: user.validatedEmail
        )
        try await cache.set(.refreshTokenKey(for: user.requireID().uuidString, clientID: clientID), to: refreshToken, expiresIn: .days(14))

        return (accessToken: accessToken, refreshToken: refreshToken, idToken: idToken)
    }
    
    private func verifyEmailIfNecessary(for user: User, queue: any Queue, cache: any Vapor.Cache) async throws {
        guard !user.validatedEmail, try await cache.get(.userToEmailVerificationTokenKey(for: user.requireID().uuidString), as: String.self) == nil else { return }
        let token = EmailVerificationToken()
        try await cache.set(.userToEmailVerificationTokenKey(for: user.requireID().uuidString), to: token, expiresIn: .days(30))
        try await cache.set(.emailVerificationTokenToUserKey(for: token.content), to: user.requireID(), expiresIn: .days(30))
        try await queue.dispatch(EmailJob.self, .init(personalizations: [Personalization(to: [EmailAddress(stringLiteral: user.email.mailbox)],
                                                                                         subject: "Verify Your Email")],
                                                      from: "tyler.keith.thompson@gmail.com",
                                                      content: [EmailContent(stringLiteral: "To verify your email, follow this link: \(Container.hostConfig().hostingURL)/users/verifyEmail/\(token.content)")]))

    }
}

extension Validator where T == String {
    /// Validates whether a `String` is a valid email address.
    public static var rfcCompliantEmail: Validator<T> {
        .init {
            ValidatorResults.RFCCompliantEmail(isValidEmail: (try? Email($0)) != nil)
        }
    }
}

extension ValidatorResults {
    /// `ValidatorResult` of a validator that validates whether a `String` is a valid email address.
    public struct RFCCompliantEmail: ValidatorResult {
        /// The input is a valid email address
        public let isValidEmail: Bool
        
        public var isFailure: Bool {
            !self.isValidEmail
        }
        
        public var successDescription: String? {
            "is a valid email address"
        }
        
        public var failureDescription: String? {
            "is not a valid email address"
        }
    }
}

extension PublicKeyCredentialCreationOptions: @retroactive AsyncResponseEncodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        var headers = HTTPHeaders()
        headers.contentType = .json
        return try Response(status: .ok, headers: headers, body: .init(data: JSONEncoder().encode(self)))
    }
}

extension PublicKeyCredentialRequestOptions: @retroactive AsyncResponseEncodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        var headers = HTTPHeaders()
        headers.contentType = .json
        return try Response(status: .ok, headers: headers, body: .init(data: JSONEncoder().encode(self)))
    }
}

extension String {
    static func accessTokenRevokedKey(for sub: String, clientID: String) -> String {
        "\(sub)_\(clientID)_accessToken_revoked"
    }
    
    static func refreshTokenKey(for sub: String, clientID: String) -> String {
        "\(sub)_\(clientID)_refreshToken"
    }
    
    static func userToEmailVerificationTokenKey(for sub: String) -> String {
        "\(sub)_emailVerificationToken"
    }
    
    static func emailVerificationTokenToUserKey(for token: String) -> String {
        "\(token)_userMapping"
    }
}
