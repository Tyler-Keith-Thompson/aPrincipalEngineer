//
//  BlogViewControllerTests.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/9/24.
//

#if os(macOS)
import XCTVapor
import Testing
import DependencyInjection
import FluentSQLiteDriver
import JWT
import Email
import XCTQueues
import Views
import Cuckoo

@testable import App

struct BlogViewControllerTests {
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
    
//    let blog = routes.grouped(User.sessionAuthenticator()).grouped("blog")
//    blog.get(use: self.blogSearch)
//    blog.get(":blogID", use: self.postWithID)
//    let console = blog
//        .grouped(User.sessionAuthenticator())
//        .grouped(UserBearerAuthenticator())
//        .grouped(User.guardMiddleware())
//    
//    console.group("new_post") { newPost in
//        newPost.get(use: self.newPost)
//        newPost.post("web_publish", body: .collect(maxSize: "100kb"), use: self.webPublish)
//    }
//    
//    console.group("edit_post") { editPost in
//        editPost.get(":blogID", use: self.editPost)
//        editPost.post("web_update", body: .collect(maxSize: "100kb"), use: self.webUpdate)
//    }
    @Test func getSpecificBlogPost() async throws {
        try await withApp { app in
            MockOpenFGAService().withStub { stub in
                when(stub.createRelation(client: any(), tuples: any())).thenDoNothing()
                when(stub.deleteRelation(client: any(), tuples: any())).thenDoNothing()
                when(stub.checkAuthorization(client: any(), tuples: any(), contextualTuples: any())).thenReturn(true)
            }.storeIn(Container.openFGAService)
            
            let postQueryResult = try await BlogPost.query(on: app.db)
                .with(\.$tags)
                .with(\.$author)
                .first()
            
            let post = try #require(postQueryResult)
            let viewBlogPost = try post.toViewBlogPost()

            try await app.test(.GET, "blog/\(try post.requireID())", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == PostDetail(blog: viewBlogPost).render())
            })
        }
    }
}
#endif
