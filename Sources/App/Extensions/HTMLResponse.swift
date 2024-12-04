//
//  HTMLResponse.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/4/24.
//

import Vapor
import Elementary
import VaporElementary

extension HTMLResponse {
    init(chunkSize: Int = 1024, additionalHeaders: HTTPHeaders = [:], @HTMLBuilder content: () throws -> some HTML & Sendable) throws {
        let html = try content()
        self.init(chunkSize: chunkSize, additionalHeaders: additionalHeaders) { html }
    }
}
