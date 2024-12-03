//
//  RedisConfig.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import DependencyInjection
import Vapor
import Redis

extension Container {
    static let redisConfiguration = Factory {
        if let redisURLString = Environment.get("REDIS_URL"),
           let redisURL = URL(string: redisURLString) {
            return try RedisConfiguration(url: redisURL, pool: .init(connectionRetryTimeout: .seconds(60)))
        }
        throw Application.Error.noRedisURL
    }
}
