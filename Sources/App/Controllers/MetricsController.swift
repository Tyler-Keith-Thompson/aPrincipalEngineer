//
//  MetricsController.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Foundation
import Vapor
import Metrics
import Prometheus

struct MetricsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("metrics") { req -> String in
            var buffer = [UInt8]()
            PrometheusMetricsFactory.defaultRegistry.emit(into: &buffer)
            return String(decoding: buffer, as: Unicode.UTF8.self)
        }
    }
}
