//
//  OpenFGACheckRequest.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/7/24.
//

import Foundation
import Vapor

struct OpenFGACheckRequest: Content, Hashable {
    let authorization_model_id: String?
    let tuple_key: OpenFGATuple
    let contextual_tuples: OpenFGAContextualTuples
    let correlation_id: UUID
    
    init(authorization_model_id: String?, tuple_key: OpenFGATuple, contextual_tuples: OpenFGAContextualTuples) {
        self.authorization_model_id = authorization_model_id
        self.tuple_key = tuple_key
        self.contextual_tuples = contextual_tuples
        self.correlation_id = tuple_key.correlationID
    }
}
