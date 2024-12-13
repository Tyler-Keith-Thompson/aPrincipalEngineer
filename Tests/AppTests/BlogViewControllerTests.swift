//
//  BlogViewControllerTests.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/9/24.
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
    
//    let blog = routes.grouped(User.sessionAuthenticator()).grouped("blog")
//    blog.get(use: self.blogSearch)
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
            Container.openFGAService.register {
                MockOpenFGAService().withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: {
                                        if tuple.relation == "can_edit" {
                                            return false
                                        } else {
                                            return true
                                        }
                                    }(), id: tuple.correlationID)
                                }))
                        }
                }
            }
            
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
    
    @Test func getSpecificBlogPost_WhenUserCanEdit() async throws {
        try await withApp { app in
            Container.openFGAService.register {
                MockOpenFGAService().withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: true, id: tuple.correlationID)
                                }))
                        }
                }
            }
            
            let postQueryResult = try await BlogPost.query(on: app.db)
                .with(\.$tags)
                .with(\.$author)
                .first()
            
            let post = try #require(postQueryResult)
            let viewBlogPost = try post.toViewBlogPost()

            try await app.test(.GET, "blog/\(try post.requireID())", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == PostDetail(blog: viewBlogPost).environment(user: nil, canEditBlogPost: true).render())
            })
        }
    }
    
    @Test func getSpecificBlogPost_WhenUserCannotView() async throws {
        try await withApp { app in
            Container.openFGAService.register {
                MockOpenFGAService().withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: false, id: tuple.correlationID)
                                }))
                        }
                }
            }
            
            let postQueryResult = try await BlogPost.query(on: app.db)
                .with(\.$tags)
                .with(\.$author)
                .first()
            
            let post = try #require(postQueryResult)

            try await app.test(.GET, "blog/\(try post.requireID())", afterResponse: { res async in
                #expect(res.status == .forbidden)
            })
        }
    }
    
    @Test func getSpecificBlogPost_WhenPostDoesNotExist() async throws {
        try await withApp { app in
            try await app.test(.GET, "blog/\(UUID())", afterResponse: { res async in
                #expect(res.status == .notFound)
            })
        }
    }
    
    @Test func newBlogPost() async throws {
        try await withApp { app in
            Container.openFGAService.register {
                MockOpenFGAService().withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: true, id: tuple.correlationID)
                                }))
                        }
                }
            }

            let user = User(email: try Email("test@example.com"), validatedEmail: true)
            let sessionCookie = try await user.createSession(app: app)
            
            try await app.test(.GET, "blog/new_post", beforeRequest: { req in
               req.headers.add(name: .cookie, value: sessionCookie)
            }, afterResponse: { res async in
                do {
                    let csrfToken = try #require(app.sessions.memory.storage.sessions.first?.value["__VaporCSRFSessionKey"])
                    
                    #expect(res.status == .ok)
                    let expectedBody = try await NewPostPage()
                        .environment(user: user)
                        .environment(csrfToken: csrfToken)
                        .renderAsync()

                    #expect(
                        res.body.string
                        ==
                        expectedBody
                    )
                } catch {
                    Issue.record(error)
                }
            })
        }
    }
    
    @Test func newBlogPost_ReturnsUnauthorizedWithNoUser() async throws {
        try await withApp { app in
            Container.openFGAService.register {
                MockOpenFGAService().withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: true, id: tuple.correlationID)
                                }))
                        }
                }
            }

            let user = User(email: try Email("test@example.com"), validatedEmail: true)
            
            try await app.test(.GET, "blog/new_post", afterResponse: { res async in
                #expect(res.status == .unauthorized)
            })
        }
    }
    
    @Test func newBlogPost_ReturnsForbiddenWithNoAuthorization() async throws {
        try await withApp { app in
            Container.openFGAService.register {
                MockOpenFGAService().withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: false, id: tuple.correlationID)
                                }))
                        }
                }
            }

            let user = User(email: try Email("test@example.com"), validatedEmail: true)
            let sessionCookie = try await user.createSession(app: app)
            
            try await app.test(.GET, "blog/new_post", beforeRequest: { req in
               req.headers.add(name: .cookie, value: sessionCookie)
            }, afterResponse: { res async in
                #expect(res.status == .forbidden)
            })
        }
    }
    
    @Test func editBlogPost() async throws {
        try await withApp { app in
            Container.openFGAService.register {
                MockOpenFGAService().withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: true, id: tuple.correlationID)
                                }))
                        }
                }
            }

            let postQueryResult = try await BlogPost.query(on: app.db)
                .with(\.$tags)
                .with(\.$author)
                .first()
            
            let post = try #require(postQueryResult)
            let viewBlogPost = try post.toViewBlogPost()

            let user = User(email: try Email("test@example.com"), validatedEmail: true)
            let sessionCookie = try await user.createSession(app: app)
            
            try await app.test(.GET, "blog/edit_post/\(post.requireID())", beforeRequest: { req in
               req.headers.add(name: .cookie, value: sessionCookie)
            }, afterResponse: { res async in
                do {
                    let csrfToken = try #require(app.sessions.memory.storage.sessions.first?.value["__VaporCSRFSessionKey"])
                    
                    #expect(res.status == .ok)
                    let expectedBody = try await EditPostPage(post: viewBlogPost)
                        .environment(user: user, canEditBlogPost: true)
                        .environment(csrfToken: csrfToken)
                        .renderAsync()

                    #expect(
                        res.body.string
                        ==
                        expectedBody
                    )
                } catch {
                    Issue.record(error)
                }
            })
        }
    }
    
    @Test func editBlogPost_ReturnsNotFoundIfPostIDIsWrong() async throws {
        try await withApp { app in
            Container.openFGAService.register {
                MockOpenFGAService().withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: true, id: tuple.correlationID)
                                }))
                        }
                }
            }

            let user = User(email: try Email("test@example.com"), validatedEmail: true)
            let sessionCookie = try await user.createSession(app: app)
            
            try await app.test(.GET, "blog/edit_post/\(UUID())", beforeRequest: { req in
               req.headers.add(name: .cookie, value: sessionCookie)
            }, afterResponse: { res async in
                #expect(res.status == .notFound)
            })
        }
    }
    
    @Test func editBlogPost_ReturnsUnauthorizedWithNoUser() async throws {
        try await withApp { app in
            Container.openFGAService.register {
                MockOpenFGAService().withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: true, id: tuple.correlationID)
                                }))
                        }
                }
            }

            let postQueryResult = try await BlogPost.query(on: app.db)
                .with(\.$tags)
                .with(\.$author)
                .first()
            
            let post = try #require(postQueryResult)

            try await app.test(.GET, "blog/edit_post/\(post.requireID())", afterResponse: { res async in
                #expect(res.status == .unauthorized)
            })
        }
    }

    @Test func editBlogPost_ReturnsForbiddenWithoutAuthorization() async throws {
        try await withApp { app in
            Container.openFGAService.register {
                MockOpenFGAService().withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: false, id: tuple.correlationID)
                                }))
                        }
                }
            }

            let postQueryResult = try await BlogPost.query(on: app.db)
                .with(\.$tags)
                .with(\.$author)
                .first()
            
            let post = try #require(postQueryResult)

            let user = User(email: try Email("test@example.com"), validatedEmail: true)
            let sessionCookie = try await user.createSession(app: app)
            
            try await app.test(.GET, "blog/edit_post/\(post.requireID())", beforeRequest: { req in
               req.headers.add(name: .cookie, value: sessionCookie)
            }, afterResponse: { res async in
                #expect(res.status == .forbidden)
            })
        }
    }
}
