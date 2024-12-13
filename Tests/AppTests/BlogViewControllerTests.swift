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
    init() {
        Matcher.register((any _OpenFGATuple).self, match: {
            $0.user == $1.user
            && $0.relation == $1.relation
            && $0.object == $1.object
        })
    }
    
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
    
    @Test func publishNewPost() async throws {
        struct CreatePostRequest: Content {
            let post_title: String
            let post_tags: String
            let post_description: String
            let post_content: String
            let csrfToken: String
        }
        try await withApp { app in
            let mockOpenFGAService = MockOpenFGAService()
            Container.openFGAService.register {
                mockOpenFGAService.withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: true, id: tuple.correlationID)
                                }))
                        }
                }
            }
            
            let newUser = User(email: try Email("test@example.com"), validatedEmail: true)
            let sessionCookie = try await newUser.createSession(app: app)
            
            let queriedUser = try await User.query(on: app.db).all().first { $0.email.mailbox == "test@example.com" }
            let user = try #require(queriedUser)
            
            let request = CreatePostRequest(post_title: UUID().uuidString,
                                            post_tags: "\(UUID().uuidString) \(UUID().uuidString)",
                                            post_description: UUID().uuidString,
                                            post_content: UUID().uuidString,
                                            csrfToken: [UInt8].random(count: 32).base64)
            
            
            app.sessions.memory.storage.sessions.keys.forEach {
                app.sessions.memory.storage.sessions[$0]?["__VaporCSRFSessionKey"] = request.csrfToken
            }
            
            try await app.test(.POST, "blog/new_post/web_publish", beforeRequest: { req in
                req.headers.add(name: .cookie, value: sessionCookie)
                try req.content.encode(request)
            }, afterResponse: { res async in
                do {
                    #expect(res.status == .seeOther)
                    let postQueryResult = try await BlogPost.query(on: app.db)
                        .with(\.$tags)
                        .with(\.$author)
                        .filter(\.$title == request.post_title)
                        .first()
                    
                    let post = try #require(postQueryResult)
                    
                    #expect(post.status == .published)
                    #expect(post.title == request.post_title)
                    #expect(post.description == request.post_description)
                    #expect(post.content == request.post_content)
                    #expect(post.author?.email.mailbox == user.email.mailbox)
                    #expect(post.tags.count == request.post_tags.components(separatedBy: " ").count)
                    #expect(post.tags.map(\.canonicalTitle).sorted() == request.post_tags.components(separatedBy: " ").map { $0.lowercased() }.sorted())
                    verify(mockOpenFGAService)
                        .createRelation(client: .any, tuples: .value([
                            try OpenFGATuple(user: App.System.global, relation: .system, object: post),
                            try OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: post),
                            try OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: post),
                            try OpenFGATuple(user: user, relation: .author, object: post),
                        ])).called(1)
                } catch {
                    Issue.record(error)
                }
            })
        }
    }
    
    @Test func publishNewPost_WithOnlyExistingTags() async throws {
        struct CreatePostRequest: Content {
            let post_title: String
            let post_tags: String
            let post_description: String
            let post_content: String
            let csrfToken: String
        }
        try await withApp { app in
            let mockOpenFGAService = MockOpenFGAService()
            Container.openFGAService.register {
                mockOpenFGAService.withStub {
                    $0.createRelation(client: .any, tuples: .any).willReturn()
                        .deleteRelation(client: .any, tuples: .any).willReturn()
                        .checkAuthorization(client: .any, tuples: .any, contextualTuples: .any).willProduce { _, tuples, _ in
                                .init(result: .init(responses: tuples.map { tuple in
                                    OpenFGACheckResponse(allowed: true, id: tuple.correlationID)
                                }))
                        }
                }
            }
            
            let newUser = User(email: try Email("test@example.com"), validatedEmail: true)
            let sessionCookie = try await newUser.createSession(app: app)
            
            let queriedUser = try await User.query(on: app.db).all().first { $0.email.mailbox == "test@example.com" }
            let user = try #require(queriedUser)
            let allTags = try await Tag.query(on: app.db).all()
            
            let request = CreatePostRequest(post_title: UUID().uuidString,
                                            post_tags: allTags.map(\.canonicalTitle).joined(separator: " "),
                                            post_description: UUID().uuidString,
                                            post_content: UUID().uuidString,
                                            csrfToken: [UInt8].random(count: 32).base64)
            
            
            app.sessions.memory.storage.sessions.keys.forEach {
                app.sessions.memory.storage.sessions[$0]?["__VaporCSRFSessionKey"] = request.csrfToken
            }
            
            try await app.test(.POST, "blog/new_post/web_publish", beforeRequest: { req in
                req.headers.add(name: .cookie, value: sessionCookie)
                try req.content.encode(request)
            }, afterResponse: { res async in
                do {
                    #expect(res.status == .seeOther)
                    let postQueryResult = try await BlogPost.query(on: app.db)
                        .with(\.$tags)
                        .with(\.$author)
                        .filter(\.$title == request.post_title)
                        .first()
                    
                    let post = try #require(postQueryResult)
                    
                    #expect(post.status == .published)
                    #expect(post.title == request.post_title)
                    #expect(post.description == request.post_description)
                    #expect(post.content == request.post_content)
                    #expect(post.author?.email.mailbox == user.email.mailbox)
                    #expect(post.tags.count == request.post_tags.components(separatedBy: " ").count)
                    #expect(post.tags.map(\.canonicalTitle).sorted() == request.post_tags.components(separatedBy: " ").map { $0.lowercased() }.sorted())
                    let allTagsAfterSave = try await Tag.query(on: app.db).all()
                    #expect(allTags.map(\.canonicalTitle).sorted() == allTagsAfterSave.map(\.canonicalTitle).sorted())
                    
                    verify(mockOpenFGAService)
                        .createRelation(client: .any, tuples: .value([
                            try OpenFGATuple(user: App.System.global, relation: .system, object: post),
                            try OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: post),
                            try OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: post),
                            try OpenFGATuple(user: user, relation: .author, object: post),
                        ])).called(1)
                } catch {
                    Issue.record(error)
                }
            })
        }
    }
}
