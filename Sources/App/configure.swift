//
//  configure.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import NIOSSL
import JWTKit
import Fluent
import Vapor
import DependencyInjection
import VaporSecurityHeaders

extension Application {
    enum Error: Swift.Error {
        case noRedisURL
        case noDatabaseURL
    }
}

extension Application.Queues.Provider: @unchecked @retroactive Sendable { }

// configures your application
public func configure(_ app: Application) async throws {
    (try? Container.redisConfiguration()).flatMap { app.redis.configuration = $0 }
    try app.sessions.use(Container.sessionProvider())
    app.sessions.configuration = Container.sessionConfigurationFactory().config(for: app)

    try app.caches.use(Container.cacheProvider())
    try app.queues.use(Container.queueProvider())

    let config = try Container.databaseConfig()
    app.databases.use(config.database, as: config.id)
    
    app.migrations.add(User.Migration())
    app.migrations.add(WebAuthnCredential.Migration())
#if DEBUG
    app.migrations.add(User.DebugMigration())
#endif
    app.migrations.add(Tag.Migration())
    app.migrations.add(BlogPost.Migration())
    app.migrations.add(BlogPostTag.Migration())
    app.migrations.add(NetlifyBlogPostsMigration())

    //Register jobs
    let emailJob = EmailJob()
    app.queues.add(emailJob)
    app.queues.configuration.refreshInterval = .minutes(1)
    try app.queues.startInProcessJobs(on: .default)
    try app.queues.startScheduledJobs()
    
    let hostConfig = Container.hostConfig()
    let cspConfig = ContentSecurityPolicyConfiguration(value: ContentSecurityPolicy()
        .defaultSrc(sources: CSPKeywords.none)
        .scriptSrc(sources: hostConfig.hostingURL)
        .styleSrc(sources: hostConfig.hostingURL, CSPKeywords.unsafeInline)
        .imgSrc(sources: hostConfig.hostingURL, "data:")
        .fontSrc(sources: hostConfig.hostingURL)
        .manifestSrc(sources: hostConfig.hostingURL)
        .connectSrc(sources: hostConfig.hostingURL)
        .formAction(sources: CSPKeywords.`self`)
        .upgradeInsecureRequests(app.environment == .production)
        .blockAllMixedContent())
    
    let strictTransportSecurityConfig = StrictTransportSecurityConfiguration(maxAge: 31536000, includeSubdomains: true, preload: true)
    let referrerPolicyConfig = ReferrerPolicyConfiguration(.noReferrer)
    let securityHeadersFactory = SecurityHeadersFactory()
        .with(contentSecurityPolicy: cspConfig)
        .with(strictTransportSecurity: strictTransportSecurityConfig)
        .with(referrerPolicy: referrerPolicyConfig)
    app.middleware = Middlewares()
    app.middleware.use(securityHeadersFactory.build())
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    app.middleware.use(Container.fileMiddlewareFactory().middleware(for: app))
    app.middleware.use(app.sessions.middleware)

    if let JWK_KEY_1 = Environment.get("JWK_PRIVATE_1") {
        try await Container.userAuthenticatorKeyStore().add(ecdsa: ECDSA.PrivateKey<P256>(pem: JWK_KEY_1))
    } else {
        await Container.userAuthenticatorKeyStore().add(ecdsa: ECDSA.PrivateKey<P256>())
    }
    
    // register routes
    try routes(app)
}

extension ContentSecurityPolicy {
    @discardableResult
    public func upgradeInsecureRequests(_ val: Bool) -> ContentSecurityPolicy {
        if val {
            return self.upgradeInsecureRequests()
        } else {
            return self
        }
    }
}
