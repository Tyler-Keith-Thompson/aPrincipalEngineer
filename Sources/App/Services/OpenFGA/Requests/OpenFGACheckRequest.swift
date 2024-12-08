//
//  OpenFGACheckRequest.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/7/24.
//

import Vapor

struct OpenFGACheckRequest: Content, Hashable {
    let authorization_model_id: String?
    let tuple_key: OpenFGATuple
    let contextual_tuples: OpenFGAContextualTuples
}
