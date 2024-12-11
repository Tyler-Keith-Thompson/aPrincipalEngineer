// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "aPrincipalEngineer",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        // Server
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/brokenhandsio/VaporSecurityHeaders.git", from: "4.2.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.11.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.1.2"),
        .package(url: "https://github.com/vapor/queues.git", from: "1.16.1"),
        .package(url: "https://github.com/vapor-community/sendgrid.git", from: "6.0.0-rc.1"),
        .package(url: "https://github.com/brokenhandsio/vapor-csrf.git", from: "1.0.0"),
        
        // View rendering
        .package(url: "https://github.com/sliemeobn/elementary.git", from: "0.4.1"),
        .package(url: "https://github.com/sliemeobn/elementary-htmx.git", from: "0.3.0"),
        .package(url: "https://github.com/vapor-community/vapor-elementary.git", from: "0.2.0"),
        .package(url: "https://github.com/JohnSundell/Ink.git", from: "0.6.0"),
        
        // Database
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.8.0"),
        
        // Metrics
        .package(url: "https://github.com/apple/swift-metrics.git", from: "2.5.0"),
        .package(url: "https://github.com/apple/swift-metrics-extras.git", from: "0.3.1"),
        .package(url: "https://github.com/swift-server-community/SwiftPrometheus.git", from: "2.0.0"),
        
        // Distributed tracing
        .package(url: "https://github.com/apple/swift-distributed-tracing.git", from: "1.1.2"),
        .package(url: "https://github.com/apple/swift-distributed-tracing-extras.git", from: "1.0.0-beta.1"),
        .package(url: "https://github.com/slashmo/swift-otel.git", from: "0.10.1"),
        
        // Auth
        .package(url: "https://github.com/vapor/jwt.git", from: "5.1.1"),
        .package(url: "https://github.com/swift-server/webauthn-swift.git", from: "1.0.0-alpha.2"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.10.0"),
        
        // Code
        .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.13.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
        .package(url: "https://github.com/Tyler-Keith-Thompson/Afluent.git", from: "0.6.13"),
        .package(url: "https://github.com/Tyler-Keith-Thompson/DependencyInjection.git", from: "0.0.12"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0"),
        
        // Documentation
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        
        // Tests
//        .package(url: "https://github.com/Brightify/Cuckoo.git", from: "2.0.10"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                // Server
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "VaporSecurityHeaders", package: "VaporSecurityHeaders"),
                .product(name: "Redis", package: "redis"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
                .product(name: "SendGrid", package: "sendgrid"),
                .product(name: "VaporCSRF", package: "vapor-csrf"),
                
                // View rendering
                .product(name: "Elementary", package: "elementary"),
                .product(name: "ElementaryHTMX", package: "elementary-htmx"),
                .product(name: "VaporElementary", package: "vapor-elementary"),
                .product(name: "Ink", package: "Ink"),

                // Database
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                
                // Metrics
                .product(name: "Metrics", package: "swift-metrics"),
                .product(name: "SystemMetrics", package: "swift-metrics-extras"),
                .product(name: "Prometheus", package: "SwiftPrometheus"),
                
                // Distributed tracing
                .product(name: "Tracing", package: "swift-distributed-tracing"),
                .product(name: "TracingOpenTelemetrySemanticConventions", package: "swift-distributed-tracing-extras"),
                .product(name: "OTel", package: "swift-otel"),
                .product(name: "OTLPGRPC", package: "swift-otel"),
                
                // Auth
                .product(name: "JWT", package: "jwt"),
                .product(name: "WebAuthn", package: "webauthn-swift"),
                .product(name: "Crypto", package: "swift-crypto"),
                
                // Code
                .product(name: "Afluent", package: "Afluent"),
                .product(name: "DependencyInjection", package: "DependencyInjection"),
                .product(name: "Atomics", package: "swift-atomics"),
                "Email",
                "Views",
            ],
            resources: [
                .copy("Public/"),
            ]
        ),
        .target(
            name: "Email",
            dependencies: [
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]),
        .target(
            name: "Views",
            dependencies: [
                .product(name: "Elementary", package: "elementary"),
                .product(name: "ElementaryHTMX", package: "elementary-htmx"),
                .product(name: "Ink", package: "Ink"),
                .product(name: "Afluent", package: "Afluent"),
            ]),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
                .product(name: "XCTQueues", package: "queues"),
//                .product(name: "Cuckoo", package: "cuckoo"),
            ],
            plugins: [
//                .plugin(name: "CuckooPluginSingleFile", package: "Cuckoo")
            ]
        ),
        .testTarget(
            name: "EmailTests",
            dependencies: ["Email"]),
    ],
    swiftLanguageModes: [.v6]
)
