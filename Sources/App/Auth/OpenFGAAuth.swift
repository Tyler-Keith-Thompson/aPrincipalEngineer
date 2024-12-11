//
//  OpenFGA.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/8/24.
//

import Vapor

extension Request.Authentication {
    var userTypeTuple: OpenFGATypeTuple {
        get throws {
            if let user = get(User.self) {
                return try .init(type: user.openFGATypeName, id: user.openFGAID)
            } else {
                return try .init(type: "guest", id: "anonymous")
            }
        }
    }
}
