//
//  OpenFGAWriteTupleRequest.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/7/24.
//

import Vapor

struct OpenFGAWriteTupleRequest: Content, Hashable {
    struct Writes: Codable, Hashable {
        let tuple_keys: [OpenFGATuple]
    }
    struct Deletes: Codable, Hashable {
        let tuple_keys: [OpenFGATuple]
    }
    let authorization_model_id: String?
    let writes: Writes?
    let deletes: Deletes?
}
