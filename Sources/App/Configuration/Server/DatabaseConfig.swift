//
//  DatabaseConfig.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import DependencyInjection
import Vapor
import FluentPostgresDriver
import FluentSQLiteDriver

extension Container {
    static let databaseConfig = Factory { () throws -> (database: DatabaseConfigurationFactory, id: DatabaseID) in
#if DEBUG
        (database: DatabaseConfigurationFactory.sqlite(.memory), id: DatabaseID.sqlite)
#else
        if let databaseURL = Environment.get("DATABASE_URL") {
            return try (database: DatabaseConfigurationFactory.postgres(url: databaseURL), id: DatabaseID.psql)
        } else {
            throw Application.Error.noDatabaseURL
        }
#endif
    }
}
