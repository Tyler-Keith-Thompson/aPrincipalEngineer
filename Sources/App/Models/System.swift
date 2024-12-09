//
//  System.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/7/24.
//

struct System: OpenFGAModel {
    enum Relation: String {
        case admin
        case editor
        case reviewer
        case content_author
    }
    
    let id: String
    var openFGAID: String { id }
    
    static let global = System(id: "global")
}
