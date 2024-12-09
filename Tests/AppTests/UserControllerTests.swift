//
//  UserControllerTests.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

@testable import App
import XCTVapor
import Testing
import Fluent
import DependencyInjection
import FluentSQLiteDriver
@testable import WebAuthn
import Email
import JWT
import XCTQueues
import Crypto
import Views
import Cuckoo

struct UserControllerTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        try await withTestContainer {
            Container.databaseConfig.register {
                (database: DatabaseConfigurationFactory.sqlite(.memory), id: DatabaseID.sqlite)
            }
            let store = JWTKeyCollection()
            await store.add(ecdsa: ECDSA.PrivateKey<P256>())
            Container.hostConfig.useProduction()
            Container.userAuthenticatorKeyStore.register { store }
            Container.redisConfiguration.register { throw Application.Error.noRedisURL }
            Container.queueProvider.register { .asyncTest }
            Container.sessionProvider.register { .memory }
            Container.webAuthnManager.useProduction()
            Container.fileMiddlewareFactory.register { Container.DebugFileMiddlewareFactory() }
            Container.sessionConfigurationFactory.register { Container.DebugSessionConfigurationFactory() }
            Container.cacheProvider.register { .memory }
            MockOpenFGAService().withStub { stub in
                when(stub.createRelation(client: any(), tuples: any())).thenDoNothing()
                when(stub.deleteRelation(client: any(), tuples: any())).thenDoNothing()
            }.storeIn(Container.openFGAService)
            let app = try await Application.make(.testing)
            do {
                try await configure(app)
                try await app.autoMigrate()
                try await test(app)
                try await app.autoRevert()
            }
            catch {
                try await app.asyncShutdown()
                throw error
            }
            try await app.asyncShutdown()
        }
    }
    
    @Test func canSuccessfullyCreateAnAccount() async throws {
        try await withApp { app in
            var cookie: String?
            
            try await app.test(.POST, "users", beforeRequest: { req in
                try req.content.encode([
                    "email": "test@example.com"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .seeOther)
                #expect(res.headers[.location].first == "users/makeCredential")
                cookie = res.headers[.setCookie].first
            })
            
            try await app.test(.GET, "users/makeCredential", beforeRequest: { req in
                try req.headers.add(name: .cookie, value: #require(cookie))
            }, afterResponse: { res async in
                #expect(res.status == .ok)
                struct Options: Decodable {
                    let challenge: URLEncodedBase64
                }
                do {
                    let options = try res.content.decode(Options.self)
                    let challengeBytes = try #require(options.challenge.decodedBytes)
                    #expect(app.sessions.memory.storage.sessions.first?.value["registrationChallenge"] == Data(challengeBytes).base64EncodedString())
                } catch {
                    Issue.record(error)
                }
            })
            
            let sessionID = try #require(app.sessions.memory.storage.sessions.first?.key)
            app.sessions.memory.storage.sessions[sessionID]?["registrationChallenge"] = Data(TestConstants.mockChallenge).base64EncodedString()
            
            struct ClientResponse: Content {
                struct Response: Content {
                    var attestationObject = TestAttestationObjectBuilder().validMock().buildBase64URLEncoded().asString()
                    var clientDataJSON = TestClientDataJSON().base64URLEncoded.asString()
                }
                var id = "mock-credential-id"
                var rawId = Data("mock-credential-id".utf8).base64EncodedString()
                var response = Response()
                var type = "public-key"
            }
            
            struct Request: Content {
                let credential: ClientResponse
                let clientID: String
            }
            try await app.test(.POST, "users/makeCredential", beforeRequest: { req in
                try req.content.encode(Request(credential: ClientResponse(), clientID: "aPrincipalEngineerClient"))
                try req.headers.add(name: .cookie, value: #require(cookie))
            }, afterResponse: { res async in
                #expect(res.status == .ok)
                do {
                    let tokenResponse = try res.content.decode(UserController.TokenResponse.self)
                    #expect(!tokenResponse.accessToken.isEmpty)
                    #expect(!tokenResponse.idToken.isEmpty)
                    let userID = try await tokenResponse.serializedAccessToken.userID(cache: app.cache)
                    let refreshToken = try await app.cache.get("\(userID)_aPrincipalEngineerClient_refreshToken", as: RefreshToken.self)
                    #expect(tokenResponse.refreshToken == refreshToken)

                    let store = Container.userAuthenticatorKeyStore()
                    let actualAccessToken: AccessToken = try await store.verify(tokenResponse.accessToken, as: AccessToken.self)
                    #expect(actualAccessToken.iss.value == "aPrincipalEngineer")
                    #expect(actualAccessToken.aud.value.first == "aPrincipalEngineerClient")
                    let actualIDToken: IDToken = try await store.verify(tokenResponse.idToken, as: IDToken.self)
                    #expect(actualIDToken.iss.value == "aPrincipalEngineer")
                    #expect(actualIDToken.aud.value.first == "aPrincipalEngineerClient")
                } catch {
                    Issue.record(error)
                }
            })
        }
    }
    
    @Test func afterCreatingAnAccount_VerificationEmailIsSent() async throws {
        try await withApp { app in
            let tokenResponse = try await createUser(app: app)
            let job = try #require(app.queues.asyncTest.first(EmailJob.self))
            #expect(job.personalizations.first(where: { $0.to != nil })?.to?.first?.email == "test@example.com")
            let userID = try await tokenResponse.serializedAccessToken.userID(cache: app.cache)
            let emailVerificationToken = try await app.cache.get("\(userID)_emailVerificationToken", as: EmailVerificationToken.self)
            let tokenText = try #require(emailVerificationToken?.content)
            #expect((job.content ?? []).contains(where: { $0.value.contains("\(Container.hostConfig().hostingURL)/users/verifyEmail/\(tokenText)") }))
            app.queues.asyncTest.jobs.removeAll()
            try await app.test(.GET, "users/verifyEmail/\(tokenText)", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == EmailVerified(username: "test@example.com").render())
            })
        }
    }
    
    @Test func creatingAnAccountFailsIfAccountAlreadyExists() async throws {
        try await withApp { app in
            try await User(email: Email("test@example.com"), validatedEmail: true).save(on: app.db)
            
            try await app.test(.POST, "users", beforeRequest: { req in
                try req.content.encode([
                    "email": "test@example.com"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .badRequest)
            })
        }
    }
    
    @Test func canAbandonAccountCreation() async throws {
        try await withApp { app in
            var cookie: String?

            try await app.test(.POST, "users", beforeRequest: { req in
                try req.content.encode([
                    "email": "test@example.com"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .seeOther)
                cookie = res.headers[.setCookie].first
            })
            
            #expect(try await User.query(on: app.db).filter(\.$email == Email("test@example.com")).first() != nil)
            
            try await app.test(.DELETE, "users/makeCredential", beforeRequest: { req in
                try req.headers.add(name: .cookie, value: #require(cookie))
            }, afterResponse: { res async in
                #expect(res.status == .noContent)
            })
            #expect(try await User.query(on: app.db).filter(\.$email == Email("test@example.com")).first() == nil)

            try await app.test(.GET, "users/makeCredential", beforeRequest: { req in
                try req.headers.add(name: .cookie, value: #require(cookie))
            }, afterResponse: { res async in
                #expect(res.status == .unauthorized)
            })
        }
    }
    
    @Test func creatingRegistrationCredentialCannotBeReplayed() async throws {
        try await withApp { app in
            var cookie: String?
            
            try await app.test(.POST, "users", beforeRequest: { req in
                try req.content.encode([
                    "email": "test@example.com"
                ])
            }, afterResponse: { res async in
                cookie = res.headers[.setCookie].first
            })
            
            try await app.test(.GET, "users/makeCredential", beforeRequest: { req in
                try req.headers.add(name: .cookie, value: #require(cookie))
            }, afterResponse: { res async in
                struct Options: Decodable {
                    let challenge: URLEncodedBase64
                }
                do {
                    let options = try res.content.decode(Options.self)
                    let challengeBytes = try #require(options.challenge.decodedBytes)
                    #expect(app.sessions.memory.storage.sessions.first?.value["registrationChallenge"] == Data(challengeBytes).base64EncodedString())
                } catch {
                    Issue.record(error)
                }
            })
            
            let sessionID = try #require(app.sessions.memory.storage.sessions.first?.key)
            app.sessions.memory.storage.sessions[sessionID]?["registrationChallenge"] = Data(TestConstants.mockChallenge).base64EncodedString()
            
            struct ClientResponse: Content {
                struct Response: Content {
                    var attestationObject = TestAttestationObjectBuilder().validMock().buildBase64URLEncoded().asString()
                    var clientDataJSON = TestClientDataJSON().base64URLEncoded.asString()
                }
                var id = "mock-credential-id"
                var rawId = Data("mock-credential-id".utf8).base64EncodedString()
                var response = Response()
                var type = "public-key"
            }
            
            struct Request: Content {
                let credential: ClientResponse
                let clientID: String
            }
            try await app.test(.POST, "users/makeCredential", beforeRequest: { req in
                try req.content.encode(Request(credential: ClientResponse(), clientID: "aPrincipalEngineerClient"))
                try req.headers.add(name: .cookie, value: #require(cookie))
            }, afterResponse: { res async in
                #expect(res.status == .ok)
            })
            
            try await app.test(.POST, "users/makeCredential", beforeRequest: { req in
                try req.content.encode(Request(credential: ClientResponse(), clientID: "aPrincipalEngineerClient"))
                try req.headers.add(name: .cookie, value: #require(cookie))
            }, afterResponse: { res async in
                #expect(res.status == .badRequest)
            })
        }
    }
    
    @Test func canSuccessfullyLogIn() async throws {
        try await withApp { app in
            var cookie: String?
            try await createUser(app: app)
            
            try await app.test(.GET, "users/authenticate", afterResponse: { res async in
                #expect(res.status == .ok)
                cookie = res.headers[.setCookie].first

                struct Options: Decodable {
                    let challenge: URLEncodedBase64
                }
                do {
                    let options = try res.content.decode(Options.self)
                    let challengeBytes = try #require(options.challenge.decodedBytes)
                    #expect(app.sessions.memory.storage.sessions.first?.value["authChallenge"] == Data(challengeBytes).base64EncodedString())
                } catch {
                    Issue.record(error)
                }
            })
            
            let sessionID = try #require(app.sessions.memory.storage.sessions.first?.key)
            app.sessions.memory.storage.sessions[sessionID]?["authChallenge"] = Data(TestConstants.mockChallenge).base64EncodedString()
            
            struct ClientResponse: Content {
                struct Response: Content {
                    var clientDataJSON = TestClientDataJSON(type: "webauthn.get").base64URLEncoded
                    var authenticatorData = TestAuthDataBuilder().validAuthenticationMock().buildAsBase64URLEncoded()
                    var signature = TestECCKeyPair.signature.base64URLEncodedString()
                    var userHandle = "36323638424436452d303831452d344331312d413743332d334444304146333345433134".hexadecimal!.base64URLEncodedString()
                }
                var id = TestConstants.mockCredentialID.base64URLEncodedString()
                var rawId = TestConstants.mockCredentialID.base64URLEncodedString()
                var response = Response()
                var authenticatorAttachment = "platform"
                var type = "public-key"
            }
            
            struct Request: Content {
                let credential: ClientResponse
                let clientID: String
            }
            try await app.test(.POST, "users/authenticate", beforeRequest: { req in
                try req.content.encode(Request(credential: ClientResponse(), clientID: "aPrincipalEngineerClient"))
                try req.headers.add(name: .cookie, value: #require(cookie))
            }, afterResponse: { res async in
                #expect(res.status == .ok)
                do {
                    let tokenResponse = try res.content.decode(UserController.TokenResponse.self)
                    #expect(!tokenResponse.accessToken.isEmpty)
                    #expect(!tokenResponse.idToken.isEmpty)
                    let userID = try await tokenResponse.serializedAccessToken.userID(cache: app.cache)
                    let refreshToken = try await app.cache.get("\(userID)_aPrincipalEngineerClient_refreshToken", as: RefreshToken.self)
                    #expect(tokenResponse.refreshToken == refreshToken)
                    
                    let store = Container.userAuthenticatorKeyStore()
                    let actualAccessToken: AccessToken = try await store.verify(tokenResponse.accessToken, as: AccessToken.self)
                    #expect(actualAccessToken.iss.value == "aPrincipalEngineer")
                    #expect(actualAccessToken.aud.value.first == "aPrincipalEngineerClient")
                    let actualIDToken: IDToken = try await store.verify(tokenResponse.idToken, as: IDToken.self)
                    #expect(actualIDToken.iss.value == "aPrincipalEngineer")
                    #expect(actualIDToken.aud.value.first == "aPrincipalEngineerClient")
                } catch {
                    Issue.record(error)
                }
            })
        }
    }
    
    @Test func cannotLogInWithoutCreatingUser() async throws {
        try await withApp { app in
            var cookie: String?
            
            try await app.test(.GET, "users/authenticate", afterResponse: { res async in
                #expect(res.status == .ok)
                cookie = res.headers[.setCookie].first
            })
            
            let sessionID = try #require(app.sessions.memory.storage.sessions.first?.key)
            app.sessions.memory.storage.sessions[sessionID]?["authChallenge"] = Data(TestConstants.mockChallenge).base64EncodedString()
            
            struct ClientResponse: Content {
                struct Response: Content {
                    var clientDataJSON = TestClientDataJSON(type: "webauthn.get").base64URLEncoded
                    var authenticatorData = TestAuthDataBuilder().validAuthenticationMock().buildAsBase64URLEncoded()
                    var signature = TestECCKeyPair.signature.base64URLEncodedString()
                    var userHandle = "36323638424436452d303831452d344331312d413743332d334444304146333345433134".hexadecimal!.base64URLEncodedString()
                }
                var id = TestConstants.mockCredentialID.base64URLEncodedString()
                var rawId = TestConstants.mockCredentialID.base64URLEncodedString()
                var response = Response()
                var authenticatorAttachment = "platform"
                var type = "public-key"
            }
            
            struct Request: Content {
                let credential: ClientResponse
                let clientID: String
            }
            try await app.test(.POST, "users/authenticate", beforeRequest: { req in
                try req.content.encode(Request(credential: ClientResponse(), clientID: "aPrincipalEngineerClient"))
                try req.headers.add(name: .cookie, value: #require(cookie))
            }, afterResponse: { res async in
                #expect(res.status == .unauthorized)
            })
        }
    }
    
    @Test func cannotReplayLogIn() async throws {
        try await withApp { app in
            var cookie: String?
            try await createUser(app: app)
            app.sessions.memory.storage.sessions.removeAll()
            
            try await app.test(.GET, "users/authenticate", afterResponse: { res async in
                #expect(res.status == .ok)
                cookie = res.headers[.setCookie].first

                struct Options: Decodable {
                    let challenge: URLEncodedBase64
                }
                do {
                    let options = try res.content.decode(Options.self)
                    _ = try #require(options.challenge.decodedBytes)
                } catch {
                    Issue.record(error)
                }
            })
            
            app.sessions.memory.storage.sessions.keys.forEach {
                app.sessions.memory.storage.sessions[$0]?["authChallenge"] = Data(TestConstants.mockChallenge).base64EncodedString()
            }
            
            struct ClientResponse: Content {
                struct Response: Content {
                    var clientDataJSON = TestClientDataJSON(type: "webauthn.get").base64URLEncoded
                    var authenticatorData = TestAuthDataBuilder().validAuthenticationMock().buildAsBase64URLEncoded()
                    var signature = TestECCKeyPair.signature.base64URLEncodedString()
                    var userHandle = "36323638424436452d303831452d344331312d413743332d334444304146333345433134".hexadecimal!.base64URLEncodedString()
                }
                var id = TestConstants.mockCredentialID.base64URLEncodedString()
                var rawId = TestConstants.mockCredentialID.base64URLEncodedString()
                var response = Response()
                var authenticatorAttachment = "platform"
                var type = "public-key"
            }
            
            struct Request: Content {
                let credential: ClientResponse
                let clientID: String
            }
            try await app.test(.POST, "users/authenticate", beforeRequest: { req in
                try req.content.encode(Request(credential: ClientResponse(), clientID: "aPrincipalEngineerClient"))
                try req.headers.add(name: .cookie, value: #require(cookie))
            }, afterResponse: { res async in
                #expect(res.status == .ok)
            })
            
            try await app.test(.POST, "users/authenticate", beforeRequest: { req in
                try req.content.encode(Request(credential: ClientResponse(), clientID: "aPrincipalEngineerClient"))
                try req.headers.add(name: .cookie, value: #require(cookie))
            }, afterResponse: { res async in
                #expect(res.status == .badRequest)
            })
        }
    }
    
    @Test func getUserDetails() async throws {
        try await withApp { app in
            let tokenResponse = try await createUser(app: app)
            let userQuery = try await User.find(tokenResponse.serializedAccessToken.userID(cache: app.cache), on: app.db)
            let user = try #require(userQuery)
            try await app.test(.GET, "users/\(user.requireID())", beforeRequest: { req in
                req.headers.add(name: .authorization, value: "Bearer \(tokenResponse.accessToken)")
            }, afterResponse: { res async in
                #expect(res.status == .ok)
                do {
                    let userResponse = try res.content.decode(UserController.UserDetailsResponse.self)
                    #expect(userResponse.id == user.id)
                    #expect(userResponse.email.mailbox == user.email.mailbox)
                    #expect(userResponse.validatedEmail == user.validatedEmail)
                } catch {
                    Issue.record(error)
                }
            })
        }
    }
    
    @Test func getUserDetails_FailsWithoutValidAuthToken() async throws {
        try await withApp { app in
            try await createUser(app: app)
            let allUsers = try await User.query(on: app.db).all()
            let user = try #require(allUsers.first)
            try await app.test(.GET, "users/\(user.id!)", afterResponse: { res async in
                #expect(res.status == .unauthorized)
            })
        }
    }
    
    @Test func getUserDetailsFailsIfDifferentIDPassed() async throws {
        try await withApp { app in
            let existingUser = try User(email: Email("test@test.com"), validatedEmail: false)
            try await existingUser.save(on: app.db)
            let accessToken = try await createUser(app: app).accessToken
            let allUsers = try await User.query(on: app.db).all()
            _ = try #require(allUsers.first { $0.id != existingUser.id })
            try await app.test(.GET, "users/\(existingUser.id!)", beforeRequest: { req in
                try req.headers.add(name: .authorization, value: "Bearer \(#require(accessToken))")
            }, afterResponse: { res async in
                #expect(res.status == .unauthorized)
            })
        }
    }
    
    @Test func getUserDetailsFailsIfNonExistantIDPassed() async throws {
        try await withApp { app in
            let accessToken = try await createUser(app: app).accessToken
            let allUsers = try await User.query(on: app.db).all()
            let user = try #require(allUsers.first)
            let id = user.id!
            try await user.delete(on: app.db)
            try await app.test(.GET, "users/\(id)", beforeRequest: { req in
                try req.headers.add(name: .authorization, value: "Bearer \(#require(accessToken))")
            }, afterResponse: { res async in
                #expect(res.status == .unauthorized || res.status == .notFound)
            })
        }
    }
    
    @Test func deleteUser() async throws {
        try await withApp { app in
            let accessToken = try await createUser(app: app).accessToken
            let allUsers = try await User.query(on: app.db).all()
            let user = try #require(allUsers.first)
            let id = user.id!
            try await app.test(.DELETE, "users/\(id)", beforeRequest: { req in
                try req.headers.add(name: .authorization, value: "Bearer \(#require(accessToken))")
            }, afterResponse: { res async in
                #expect(res.status == .noContent)
            })
        }
    }
    
    @Test func deleteUser_FailsIfUnauthenticated() async throws {
        try await withApp { app in
            try await createUser(app: app)
            let allUsers = try await User.query(on: app.db).all()
            let user = try #require(allUsers.first)
            let id = user.id!
            try await app.test(.DELETE, "users/\(id)", afterResponse: { res async in
                #expect(res.status == .unauthorized)
            })
        }
    }
    
    @Test func showUserProfile() async throws {
        try await withApp { app in
            let user = try User(email: Email("test@example.com"), validatedEmail: true)
            let cookie = try await user.createSession(app: app)
            try await app.test(.GET, "users/profile", beforeRequest: { req in
                req.headers.add(name: .cookie, value: cookie)
            }, afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == Profile().environment(EnvironmentValue.$user, .init(isLoggedIn: true, email: user.email.mailbox)).render())
            })
        }
    }
    
    @Test func refreshTokens() async throws {
        try await withApp { app in
            let user = try User(email: Email("test@example.com"), validatedEmail: true)
            try await user.save(on: app.db)
            let clientID = UUID().uuidString
            let (accessToken, refreshToken) = try await createValidJWTs(with: app, user: user, clientID: clientID)
            try await app.cache.set("\(user.requireID())_\(clientID)_refreshToken", to: refreshToken)
            let request = UserController.RefreshRequest(refreshToken: refreshToken)
            try await app.test(.POST, "users/refresh", beforeRequest: { req async in
                do {
                    try req.content.encode(request)
                    try await req.headers.add(name: .authorization, value: "Bearer \(accessToken.sign())")
                } catch {
                    Issue.record(error)
                }
            }, afterResponse: { res async in
                #expect(res.status == .ok)
                do {
                    let response = try res.content.decode(UserController.TokenResponse.self)
                    #expect(!response.accessToken.isEmpty)
                    #expect(response.refreshToken != refreshToken)
                    #expect(!response.idToken.isEmpty)
                    let actualRefreshToken: RefreshToken? = try await app.cache.get("\(user.requireID())_\(clientID)_refreshToken")
                    #expect(actualRefreshToken == response.refreshToken)
                    
                    let store = Container.userAuthenticatorKeyStore()
                    let actualAccessToken: AccessToken = try await store.verify(response.accessToken, as: AccessToken.self)
                    #expect(actualAccessToken.iss.value == "aPrincipalEngineer")
                    #expect(actualAccessToken.aud.value.first == clientID)
                    let actualIDToken: IDToken = try await store.verify(response.idToken, as: IDToken.self)
                    #expect(actualIDToken.iss.value == "aPrincipalEngineer")
                    #expect(actualIDToken.aud.value.first == clientID)
                } catch {
                    Issue.record(error)
                }
            })
        }
    }
    
    @Test func refreshEndpointCannotBeReplayed() async throws {
        try await withApp { app in
            let user = try User(email: Email("test@example.com"), validatedEmail: true)
            try await user.save(on: app.db)
            let clientID = UUID().uuidString
            let (accessToken, refreshToken) = try await createValidJWTs(with: app, user: user, clientID: clientID)
            try await app.cache.set("\(user.requireID())_\(clientID)_refreshToken", to: refreshToken)
            let request = UserController.RefreshRequest(refreshToken: refreshToken)
            try await app.test(.POST, "users/refresh", beforeRequest: { req async in
                do {
                    try req.content.encode(request)
                    try await req.headers.add(name: .authorization, value: "Bearer \(accessToken.sign())")
                } catch {
                    Issue.record(error)
                }
            }, afterResponse: { res async in
                #expect(res.status == .ok)
                do {
                    let response = try res.content.decode(UserController.TokenResponse.self)
                    #expect(!response.accessToken.isEmpty)
                    #expect(response.refreshToken != refreshToken)
                    #expect(!response.idToken.isEmpty)
                    let actualRefreshToken: RefreshToken? = try await app.cache.get("\(user.requireID())_\(clientID)_refreshToken")
                    #expect(actualRefreshToken == response.refreshToken)
                    
                    let store = Container.userAuthenticatorKeyStore()
                    let actualAccessToken: AccessToken = try await store.verify(response.accessToken, as: AccessToken.self)
                    #expect(actualAccessToken.iss.value == "aPrincipalEngineer")
                    #expect(actualAccessToken.aud.value.first == clientID)
                    let actualIDToken: IDToken = try await store.verify(response.idToken, as: IDToken.self)
                    #expect(actualIDToken.iss.value == "aPrincipalEngineer")
                    #expect(actualIDToken.aud.value.first == clientID)
                } catch {
                    Issue.record(error)
                }
            })
            
            try await app.test(.POST, "users/refresh", beforeRequest: { req async in
                do {
                    try req.content.encode(request)
                    try await req.headers.add(name: .authorization, value: "Bearer \(accessToken.sign())")
                } catch {
                    Issue.record(error)
                }
            }, afterResponse: { res async in
                #expect(res.status == .unauthorized)
            })
        }
    }
    
    @Test func tokenRevokedAfterLogout() async throws {
        try await withApp { app in
            let tokenResponse = try await createUser(app: app)
            let accessToken = tokenResponse.accessToken
            let refreshToken = tokenResponse.refreshToken
            let userQuery = try await User.find(tokenResponse.serializedAccessToken.userID(cache: app.cache), on: app.db)
            let user = try #require(userQuery)
            try await app.test(.GET, "users/\(user.requireID())", beforeRequest: { req in
                try req.headers.add(name: .authorization, value: "Bearer \(#require(accessToken))")
            }, afterResponse: { res async in
                #expect(res.status == .ok)
            })
            
            try await app.test(.POST, "users/logout", beforeRequest: { req in
                try req.headers.add(name: .authorization, value: "Bearer \(#require(accessToken))")
            }, afterResponse: { _ async in })
            
            try await app.test(.GET, "users/\(user.requireID())", beforeRequest: { req in
                try req.headers.add(name: .authorization, value: "Bearer \(#require(accessToken))")
            }, afterResponse: { res async in
                #expect(res.status == .unauthorized)
            })
            
            let request = UserController.RefreshRequest(refreshToken: refreshToken)
            try await app.test(.POST, "users/refresh", beforeRequest: { req async in
                do {
                    try req.content.encode(request)
                    try req.headers.add(name: .authorization, value: "Bearer \(#require(accessToken))")
                } catch {
                    Issue.record(error)
                }
            }, afterResponse: { res async in
                #expect(res.status == .unauthorized)
            })
        }
    }
    
    @Test func pseudonymousIdentity() async throws {
        let options = PseudonymousIdentifierOptions(symmetricKey: SymmetricKey(size: .bits128),
                                                    nonce: .init())
        let optionsData = try JSONEncoder().encode(options)
        let id = UUID()
        let sealedBox = try AES.GCM.seal(Data(id.uuidString.utf8), using: options.symmetricKey, nonce: options.nonce)
        let boxData = try #require(sealedBox.combined)
        let decodedOptions = try JSONDecoder().decode(PseudonymousIdentifierOptions.self, from: optionsData)
        let idString = try #require(String(data: try AES.GCM.open(try AES.GCM.SealedBox(combined: boxData), using: decodedOptions.symmetricKey), encoding: .utf8))
        let decodedID = try #require(UUID(uuidString: idString))
        #expect(decodedID == id)
    }
    
    @discardableResult private func createUser(app: Application) async throws -> UserController.TokenResponse {
        var cookie: String?
        
        try await app.test(.POST, "users", beforeRequest: { req in
            try req.content.encode([
                "email": "test@example.com"
            ])
        }, afterResponse: { res async in
            #expect(res.status == .seeOther)
            #expect(res.headers[.location].first == "users/makeCredential")
            cookie = res.headers[.setCookie].first
        })
        
        try await app.test(.GET, "users/makeCredential", beforeRequest: { req in
            try req.headers.add(name: .cookie, value: #require(cookie))
        }, afterResponse: { res async in
            #expect(res.status == .ok)
            struct Options: Decodable {
                let challenge: URLEncodedBase64
            }
            do {
                let options = try res.content.decode(Options.self)
                let challengeBytes = try #require(options.challenge.decodedBytes)
                #expect(app.sessions.memory.storage.sessions.first?.value["registrationChallenge"] == Data(challengeBytes).base64EncodedString())
            } catch {
                Issue.record(error)
            }
        })
        
        let sessionID = try #require(app.sessions.memory.storage.sessions.first?.key)
        app.sessions.memory.storage.sessions[sessionID]?["registrationChallenge"] = Data(TestConstants.mockChallenge).base64EncodedString()
        
        struct ClientResponse: Content {
            struct Response: Content {
                var attestationObject = TestAttestationObjectBuilder().validMock().buildBase64URLEncoded().asString()
                var clientDataJSON = TestClientDataJSON().base64URLEncoded.asString()
            }
            var id = TestConstants.mockCredentialID.base64URLEncodedString()
            var rawId = TestConstants.mockCredentialID.base64URLEncodedString()
            var response = Response()
            var type = "public-key"
        }
        
        struct Request: Content {
            let credential: ClientResponse
            let clientID: String
        }
        
        var tokenResponse: UserController.TokenResponse?
        try await app.test(.POST, "users/makeCredential", beforeRequest: { req in
            try req.content.encode(Request(credential: ClientResponse(), clientID: "aPrincipalEngineerClient"))
            try req.headers.add(name: .cookie, value: #require(cookie))
        }, afterResponse: { res async in
            #expect(res.status == .ok)
            do {
                let response = try res.content.decode(UserController.TokenResponse.self)
                tokenResponse = response
                #expect(!response.accessToken.isEmpty)
                #expect(!response.idToken.isEmpty)
            } catch {
                Issue.record(error)
            }
        })
        app.sessions.memory.storage.sessions.removeAll()

        return try #require(tokenResponse)
    }
    
    private func createValidJWTs(with app: Application, user: App.User, clientID: String) async throws -> (accessToken: AccessToken, refreshToken: RefreshToken) {
        let accessToken = try await AccessToken(iss: "aPrincipalEngineer",
                                                aud: .init(value: [clientID]),
                                                exp: .init(value: Date().addingTimeInterval(Measurement<UnitDuration>(value: 30, unit: .minutes).converted(to: .seconds).value)),
                                                iat: .init(value: Date()),
                                                sub: .init(user: user, clientID: clientID, cache: app.cache),
                                                email: user.email.mailbox,
                                                emailVerified: user.validatedEmail)
        let refreshToken = RefreshToken()
        return (accessToken, refreshToken)
    }
}

extension UserController.TokenResponse {
    var serializedAccessToken: AccessToken {
        get async throws {
            try await Container.userAuthenticatorKeyStore().verify(accessToken, as: AccessToken.self)
        }
    }
}
