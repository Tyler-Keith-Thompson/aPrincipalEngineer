//
//  IndexTests.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import XCTVapor
import Testing
import DependencyInjection
import FluentSQLiteDriver
import JWT
import Email
import XCTQueues
import Views
import Mockable

@testable import App

struct IndexTests {
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
            Container.fileMiddlewareFactory.register { Container.DebugFileMiddlewareFactory() }
            Container.sessionConfigurationFactory.register { Container.DebugSessionConfigurationFactory() }
            Container.sessionProvider.register { .memory }
            Container.cacheProvider.register { .memory }
            Container.openFGAService.register {
                MockOpenFGAService().withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                }
            }
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
    
    @Test func indexIsShownWhenUnAuthenticated() async throws {
        try await withApp { app in
            let posts = try await BlogPost.query(on: app.db)
                .limit(5)
                .with(\.$tags)
                .with(\.$author)
                .sort(\.$createdAt, .descending)
                .all()
            
            try await app.test(.GET, "", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == Index(posts: posts.compactMap { try? $0.toViewBlogPost() }).render())
            })
        }
    }
}

extension App.User {
    func createSession(app: Application) async throws -> String {
        var cookie: String?
        let user = self
        app.grouped(User.sessionAuthenticator()).post("test") { req in
            let user = try req.content.decode(User.self)
            try await user.save(on: req.db)
            req.auth.login(user)
            return HTTPStatus.ok
        }
        try await app.test(.POST, "test", beforeRequest: { req in
            try req.content.encode(user)
        }, afterResponse: { res async in
            cookie = res.headers[.setCookie].first
        })
        return try #require(cookie)
    }
}
