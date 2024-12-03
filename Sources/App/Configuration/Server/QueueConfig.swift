//
//  QueueConfig.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import DependencyInjection
import Vapor
import Queues
import QueuesRedisDriver

extension Container {
    static let queueProvider = Factory { () throws -> Application.Queues.Provider in
#if DEBUG
            .memory
#else
        let config = try Container.redisConfiguration()
        return .redis(config)
#endif
    }
}
