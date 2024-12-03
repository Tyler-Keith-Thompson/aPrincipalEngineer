//
//  SessionConfig.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import DependencyInjection
import Vapor
import Redis

extension Container {
    static let sessionProvider = Factory { () throws -> Application.Sessions.Provider in
#if DEBUG
            .memory
#else
        _ = try Container.redisConfiguration()
        return .redis
#endif
    }
    
    
    protocol SessionConfigurationFactory {
        func config(for: Application) -> SessionsConfiguration
    }
#if DEBUG
    struct DebugSessionConfigurationFactory: SessionConfigurationFactory {
        func config(for _: Application) -> SessionsConfiguration {
            SessionsConfiguration.default()
        }
    }
#endif
    struct ProductionSessionConfigurationFactory: SessionConfigurationFactory {
        func config(for app: Application) -> SessionsConfiguration {
            SessionsConfiguration(cookieName: app.environment == .production ? "__Host-vapor-session" : "vapor-session") {
                .init(
                    string: $0.string,
                    expires: Date(
                        timeIntervalSinceNow: 60 * 60 * 24 * 7 // one week
                    ),
                    maxAge: nil,
                    domain: nil,
                    path: "/",
                    isSecure: app.environment == .production,
                    isHTTPOnly: app.environment == .production,
                    sameSite: .strict
                )
            }
        }
    }
    static let sessionConfigurationFactory = Factory { () -> any SessionConfigurationFactory in
#if DEBUG
        DebugSessionConfigurationFactory()
#else
        ProductionSessionConfigurationFactory()
#endif
    }
}
