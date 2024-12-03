//
//  HostConfig.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import DependencyInjection
import Vapor

extension Container {
    struct HostConfig {
        let hostingURL: String
    }
    static let hostConfig = Factory {
        HostConfig(hostingURL: Environment.get("HOSTING_URL") ?? "http://localhost:8080")
    }
}
