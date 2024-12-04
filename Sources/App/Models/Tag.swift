//
//  Tag.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//

import Fluent
import Vapor

final class Tag: Model, Content, @unchecked Sendable {
    static let schema = "tags"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "canonical_title")
    var canonicalTitle: String

    @Field(key: "alternatives")
    var alternatives: [String]
    
    init() {}
    
    init(id: UUID? = nil, canonicalTitle: String, alternatives: [String] = []) {
        self.id = id
        self.canonicalTitle = canonicalTitle
        self.alternatives = alternatives
    }
}
