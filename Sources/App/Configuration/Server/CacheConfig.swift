//
//  CacheConfig.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import DependencyInjection
import Vapor
import Redis

extension Container {
    static let cacheProvider = Factory { () throws -> Application.Caches.Provider in
#if DEBUG
            .memory
#else
        _ = try Container.redisConfiguration()
        return .redis
#endif
    }
}
