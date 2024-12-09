//
//  OpenFGABatchCheckRequest.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/8/24.
//

import Vapor

struct OpenFGABatchCheckRequest: Content, Hashable {
    let checks: [OpenFGACheckRequest]
}
